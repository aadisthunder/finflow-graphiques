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

// 12-14 second per slide script: EXACTLY 2:10 to 2:20 total (under 2:30 maximum)
const scripts = {
  1: 'Welcome to FinFlow, also known as VyaparSetu. We solve the liquidity crisis for forty million street vendors in India, replacing predatory debt with algorithmic daily capital and climate protection.',
  2: 'At 4:30 AM, Raju the fruit vendor needs 3,000 rupees for wholesale mandi inventory. Slow banking forces him into predatory lenders charging over 300 percent APR, trapping his family in debt.',
  3: 'Traditional banks fail informal vendors by demanding collateral, tax returns, and rigid monthly EMIs. When heatwaves or floods hit, lenders offer zero relief, triggering default.',
  4: 'FinFlow introduces four pillars: Sunrise Capital for 4:30 AM advances, Reverse Micro-Skimming from daily UPI sales, Suraksha Goolak for emergency savings, and our Parametric Climate Shield for automated weather payouts.',
  5: 'Rajus day: at 4:30 AM, his smart soundbox disburses 3,000 rupees in seconds. Customer UPI payments auto-settle the loan in micro-slices, leaving his balance clear by evening.',
  6: 'Built on Indias Digital Public Infrastructure, FinFlow integrates OCEN 4.0, real-time UPI settlement webhooks, and our Velocity TrustScore that replaces traditional credit scores.',
  7: 'Our business model is high-margin and asset-light. A flat 20-rupee fee per daily cycle delivers an 86.8 percent net margin and a 14.8 times lifetime value to CAC ratio.',
  8: 'Forty million vendors represent an 18-billion-dollar working capital demand. Scaling to 250,000 merchants across eight trading hubs unlocks 18 million dollars in annual recurring revenue.',
  9: 'Our 15-month roadmap pilots with 1,000 vendors in Delhis Azadpur Mandi, scales with Small Finance Banks, and expands nationally to 100,000 merchants across fifteen states.',
  10: 'FinFlow saves vendors over 7,500 rupees every month, restoring economic freedom and dignity to the backbone of our economy. Thank you.'
};

async function generateSlideAudio(slideNum, text) {
  const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-tts-preview:generateContent?key=' + apiKey;
  
  const payload = {
    contents: [{
      parts: [{ text: text }]
    }],
    generationConfig: {
      responseModalities: ['AUDIO'],
      speechConfig: {
        voiceConfig: {
          prebuiltVoiceConfig: {
            voiceName: 'Charon' // Clear articulate male voice
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
  if (data.candidates && data.candidates[0].content && data.candidates[0].content.parts[0].inlineData) {
    const pcmBuffer = Buffer.from(data.candidates[0].content.parts[0].inlineData.data, 'base64');
    const wavBuffer = pcmToWav(pcmBuffer, 24000, 1, 16);
    const outPath = path.join('presentation', 'audio', `slide_${slideNum}.wav`);
    fs.writeFileSync(outPath, wavBuffer);
    const duration = (pcmBuffer.length / (24000 * 2)).toFixed(1);
    console.log(`[Slide ${slideNum}] Generated: ${outPath} (${duration}s)`);
    return { success: true, duration: parseFloat(duration), pcm: pcmBuffer };
  }
  console.error(`[Slide ${slideNum}] Failed:`, JSON.stringify(data).substring(0, 150));
  return { success: false, duration: 0 };
}

async function run() {
  console.log('Generating strictly <2m30s audio with Gemini 3.1 Flash TTS (Charon Male Voice)...');
  fs.mkdirSync(path.join('presentation', 'audio'), { recursive: true });

  const silencePause = Buffer.alloc(24000 * 2 * 0.5); // 0.5s pause
  const pcmList = [];
  let totalDuration = 0;

  for (let i = 1; i <= 10; i++) {
    let result = await generateSlideAudio(i, scripts[i]);
    if (!result.success) {
      console.log(`Retrying slide ${i}...`);
      await new Promise(r => setTimeout(r, 2000));
      result = await generateSlideAudio(i, scripts[i]);
    }
    totalDuration += result.duration;
    pcmList.push(result.pcm);
    if (i < 10) {
      pcmList.push(silencePause);
      totalDuration += 0.5;
    }
    await new Promise(r => setTimeout(r, 1000));
  }

  // Combine into single full_voiceover.wav
  const combinedPcm = Buffer.concat(pcmList);
  const combinedWav = pcmToWav(combinedPcm, 24000, 1, 16);
  fs.writeFileSync(path.join('presentation', 'audio', 'full_voiceover.wav'), combinedWav);

  console.log(`\n========================================`);
  console.log(`SUCCESS! Total video pitch duration: ${totalDuration.toFixed(1)} seconds (${(totalDuration / 60).toFixed(2)} minutes).`);
  console.log(`Saved combined file: presentation/audio/full_voiceover.wav (${(combinedWav.length / 1024 / 1024).toFixed(2)} MB)`);
  console.log(`========================================\n`);
}

run();
