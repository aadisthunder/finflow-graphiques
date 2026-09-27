const fs = require('fs');
const path = require('path');

const env = fs.readFileSync('.env', 'utf-8');
const match = env.match(/GEMINI_API_KEY=(.*)/);
if (!match) {
  console.error('No GEMINI_API_KEY found in .env');
  process.exit(1);
}
const apiKey = match[1].trim();

const slideDefinitions = {
  1: {
    phrases: [
      "Welcome to FinFlow, also known as VyaparSetu. We solve the liquidity crisis for forty million street vendors in India, replacing predatory debt with algorithmic daily capital and climate protection."
    ]
  },
  2: {
    phrases: [
      "At 4:30 AM, Raju the fruit vendor needs 3,000 rupees for wholesale mandi inventory.",
      "Slow banking forces him into predatory lenders charging over 300 percent APR,",
      "trapping his family in debt."
    ]
  },
  3: {
    phrases: [
      "Traditional banks fail informal vendors by demanding collateral, tax returns, and rigid monthly EMIs.",
      "When heatwaves or floods hit, lenders offer zero relief, triggering default."
    ]
  },
  4: {
    phrases: [
      "FinFlow introduces four pillars: Sunrise Capital for 4:30 AM advances, Reverse Micro-Skimming from daily UPI sales, Suraksha Goolak for emergency savings, and our Parametric Climate Shield for automated weather payouts."
    ]
  },
  5: {
    phrases: [
      "Rajus day: at 4:30 AM, his smart soundbox disburses 3,000 rupees in seconds.",
      "Customer UPI payments auto-settle the loan in micro-slices, leaving his balance clear by evening."
    ]
  },
  6: {
    phrases: [
      "Built on Indias Digital Public Infrastructure, FinFlow integrates OCEN 4.0,",
      "real-time UPI settlement webhooks,",
      "and our Velocity TrustScore that replaces traditional credit scores."
    ]
  },
  7: {
    phrases: [
      "Our business model is high-margin and asset-light. A flat 20-rupee fee per daily cycle delivers an 86.8 percent net margin",
      "and a 14.8 times lifetime value to CAC ratio."
    ]
  },
  8: {
    phrases: [
      "Forty million vendors represent an 18-billion-dollar working capital demand.",
      "Scaling to 250,000 merchants across eight trading hubs",
      "unlocks 18 million dollars in annual recurring revenue."
    ]
  },
  9: {
    phrases: [
      "Our 15-month roadmap pilots with 1,000 vendors in Delhis Azadpur Mandi,",
      "scales with Small Finance Banks,",
      "and expands nationally to 100,000 merchants across fifteen states."
    ]
  },
  10: {
    phrases: [
      "FinFlow saves vendors over 7,500 rupees every month,",
      "restoring economic freedom and dignity to the backbone of our economy. Thank you."
    ]
  }
};

async function analyzeSlide(slideNum) {
  const audioFile = path.join('presentation', 'audio', `slide_${slideNum}.wav`);
  const audioData = fs.readFileSync(audioFile).toString('base64');
  const def = slideDefinitions[slideNum];
  
  const prompt = `Analyze this audio and output strict JSON with exact start and end timestamps in seconds (as floats) for each of these phrases in order:
${def.phrases.map((p, idx) => `${idx + 1}. "${p}"`).join('\n')}

Format:
[
  { "phraseIndex": 0, "text": "...", "start": 0.00, "end": 6.84 },
  ...
]`;

  const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=' + apiKey;
  const payload = {
    contents: [{
      parts: [
        { text: prompt },
        { inlineData: { mimeType: 'audio/wav', data: audioData } }
      ]
    }],
    generationConfig: { responseMimeType: 'application/json' }
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });

  const data = await res.json();
  if (data.candidates && data.candidates[0].content && data.candidates[0].content.parts[0].text) {
    const parsed = JSON.parse(data.candidates[0].content.parts[0].text);
    return parsed;
  }
  throw new Error(`Failed to analyze slide ${slideNum}: ${JSON.stringify(data)}`);
}

function formatSrtTime(seconds) {
  const date = new Date(0);
  date.setUTCMilliseconds(Math.round(seconds * 1000));
  const hh = String(date.getUTCHours()).padStart(2, '0');
  const mm = String(date.getUTCMinutes()).padStart(2, '0');
  const ss = String(date.getUTCSeconds()).padStart(2, '0');
  const ms = String(date.getUTCMilliseconds()).padStart(3, '0');
  return `${hh}:${mm}:${ss},${ms}`;
}

async function run() {
  console.log('🎙️ Analyzing exact audio timestamps with Gemini 3.8 Flash...');
  const allResults = {};
  let srtEntries = [];
  let srtIndex = 1;
  let globalOffset = 0.0;

  for (let s = 1; s <= 10; s++) {
    console.log(`  - Analyzing slide_${s}.wav...`);
    const timestamps = await analyzeSlide(s);
    allResults[s] = timestamps;

    for (const item of timestamps) {
      const startGlobal = globalOffset + item.start;
      const endGlobal = globalOffset + item.end;
      srtEntries.push(`${srtIndex++}\n${formatSrtTime(startGlobal)} --> ${formatSrtTime(endGlobal)}\n${item.text}\n`);
    }

    // Read slide duration from afinfo / file size
    const stat = fs.statSync(path.join('presentation', 'audio', `slide_${s}.wav`));
    const duration = (stat.size - 44) / (24000 * 2);
    globalOffset += duration;
    if (s < 10) {
      globalOffset += 0.5; // 0.5s inter-slide pause
    }
    await new Promise(r => setTimeout(r, 600));
  }

  // Save exact_timestamps.json
  fs.writeFileSync(
    path.join('presentation', 'audio', 'exact_timestamps.json'),
    JSON.stringify(allResults, null, 2)
  );
  console.log('✅ Saved presentation/audio/exact_timestamps.json');

  // Save subtitles.srt
  fs.writeFileSync(
    path.join('presentation', 'audio', 'subtitles.srt'),
    srtEntries.join('\n')
  );
  console.log('✅ Saved presentation/audio/subtitles.srt');
}

run().catch(console.error);
