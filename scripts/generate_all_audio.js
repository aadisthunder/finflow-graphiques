const fs = require('fs');
const path = require('path');

const env = fs.readFileSync('.env', 'utf-8');
const match = env.match(/GEMINI_API_KEY=(.*)/);
if (!match) {
  console.error('No GEMINI_API_KEY found in .env');
  process.exit(1);
}
const apiKey = match[1].trim();

function pcmToWav(pcmBuffer, sampleRate = 24000, numChannels = 1, bitDepth = 16) {
  const byteRate = sampleRate * numChannels * (bitDepth / 8);
  const blockAlign = numChannels * (bitDepth / 8);
  const dataSize = pcmBuffer.length;
  const buffer = Buffer.alloc(44 + dataSize);

  buffer.write('RIFF', 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write('WAVE', 8);
  buffer.write('fmt ', 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(numChannels, 22);
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(byteRate, 28);
  buffer.writeUInt16LE(blockAlign, 32);
  buffer.writeUInt16LE(bitDepth, 34);
  buffer.write('data', 36);
  buffer.writeUInt32LE(dataSize, 40);
  pcmBuffer.copy(buffer, 44);
  return buffer;
}

const scripts = {
  1: 'Welcome to FinFlow, branded as VyaparSetu. We are addressing a critical financial challenge affecting over forty million informal street vendors and daily wage micro merchants across India. By replacing high cost informal debt with algorithmic daily cash flow skimming and autonomous climate resilience, we are redesigning informal commerce from the ground up.',
  2: 'Consider the daily reality of Raju, a fruit vendor in Delhi. Every morning at 4:30 AM, Raju needs 3,000 rupees to purchase wholesale produce at the Mandi. Formal banking is too slow, leaving vendors reliant on expensive informal lending. A single heatwave or monsoon storm spoils his fruits, disrupting his working capital and trapping his family in debt.',
  3: 'Why do traditional banks and microfinance institutions fail street vendors? Banks demand audited financial statements, tax filings, and collateral that informal workers cannot provide. Furthermore, monthly fixed EMIs ignore the daily reality of informal earnings, where sales fluctuate. When climate disruptions strike, traditional lenders offer zero protection, triggering penalties and default.',
  4: 'FinFlow introduces four breakthrough pillars. First, Sunrise Capital: automated 4:30 AM inventory advances disbursed instantly via voice command at a flat 20-rupee fee. Second, Reverse Micro-Skimming: eight to ten percent automatically deducted from incoming customer UPI QR sales during the day to clear the loan by evening. Third, Suraksha Goolak: an automated high yield rainy day reserve earning 6.5 percent interest. And fourth, our Parametric Climate Shield: instant weather triggered relief payouts during severe floods or heatwaves without claims paperwork.',
  5: 'Here is a day in the life of Raju using FinFlow. At 4:30 AM, his smart soundbox announces in Hindi that his 3,000-rupee advance is ready. Raju confirms with voice, and the funds arrive in five seconds. During the day, as customers buy fruits with UPI, small micro-slices settle the advance while Raju keeps 180 rupees immediately from every 200-rupee sale. Even when a sudden monsoon storm hits at 2 PM, our weather oracle pauses repayments and deposits emergency relief. By 8:30 PM, his advance is cleared, his Goolak savings grow, and his TrustScore increases.',
  6: 'FinFlow is engineered on Indias Digital Public Infrastructure. We leverage the Open Credit Enablement Network, OCEN 4.0, to connect regulated Small Finance Banks directly to vendors. Our high throughput webhook engine handles thousands of real-time UPI settlements per second, while our machine learning Velocity TrustScore evaluates daily transaction consistency, mandi location telemetry, and peer rings without relying on CIBIL.',
  7: 'Our business model is high margin, asset light, and inherently scalable. For an average daily loan of 2,500 rupees across 25 working days, FinFlow generates 500 rupees in monthly revenue per vendor. After deducting the cost of partner capital, cloud infrastructure, and risk provisioning, we maintain an 86.8 percent net contribution margin. With an acquisition cost of just 350 rupees through wholesale mandis, our 12-month LTV to CAC ratio exceeds 14 times.',
  8: 'The market opportunity is immense. Across South Asia, 60 million informal micro merchants generate an 18-billion-dollar daily working capital demand. In India alone, 15 million vendors already use UPI QR soundboxes. By targeting 250,000 merchants across eight dense trading hubs in our first two years, FinFlow unlocks an 18-million-dollar annual recurring revenue run rate.',
  9: 'Our execution roadmap spans 15 disciplined months. In Phase 1, we deploy our sandbox pilot across 1,000 vendors in Delhis Azadpur and Okhla Mandis. In Phase 2, we integrate with two regulated Small Finance Banks and launch our Parametric Rain Shield with insurance partners across Mumbai and Bengaluru. In Phase 3, we expand nationally to over 100,000 active merchants across 15 states.',
  10: 'The Graphiques Innovation Challenge urges us to Think Beyond Code and Create What Matters. FinFlow provides economic freedom, saving vendors over 7,500 rupees every month in avoided interest, and offers genuine climate resilience. We are restoring financial dignity to the hardworking hands that feed our nation. Thank you.'
};

async function generateSlideAudio(slideNum, text) {
  const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=' + apiKey;
  
  const payload = {
    contents: [{
      parts: [{ text: text }]
    }],
    generationConfig: {
      responseModalities: ['AUDIO'],
      speechConfig: {
        voiceConfig: {
          prebuiltVoiceConfig: {
            voiceName: 'Puck'
          }
        }
      }
    }
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });

  const data = await res.json();
  if (data.candidates && data.candidates[0].content && data.candidates[0].content.parts) {
    const part = data.candidates[0].content.parts[0];
    if (part.inlineData) {
      const pcmBuffer = Buffer.from(part.inlineData.data, 'base64');
      const wavBuffer = pcmToWav(pcmBuffer, 24000, 1, 16);
      const outPath = path.join('presentation', 'audio', `slide_${slideNum}.wav`);
      fs.writeFileSync(outPath, wavBuffer);
      console.log(`[Slide ${slideNum}] Successfully generated: ${outPath} (${(wavBuffer.length / 1024).toFixed(1)} KB)`);
      return true;
    }
  }
  console.error(`[Slide ${slideNum}] Failed:`, JSON.stringify(data).substring(0, 150));
  return false;
}

async function run() {
  console.log('Generating Gemini Indian Accent TTS for all 10 presentation slides...');
  fs.mkdirSync(path.join('presentation', 'audio'), { recursive: true });

  for (let i = 1; i <= 10; i++) {
    let success = await generateSlideAudio(i, scripts[i]);
    if (!success) {
      console.log(`Retrying slide ${i} with direct text...`);
      await new Promise(r => setTimeout(r, 2000));
      success = await generateSlideAudio(i, scripts[i]);
    }
    await new Promise(r => setTimeout(r, 1200));
  }
  console.log('Finished generating all audio files!');
}

run();
