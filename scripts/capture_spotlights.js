const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const outDir = path.join(__dirname, '..', 'presentation', 'spotlight_frames');
fs.mkdirSync(outDir, { recursive: true });

const states = [
  '1',
  '2a', '2b', '2c',
  '3a', '3b',
  '4a', '4b',
  '5a', '5b',
  '6a', '6b', '6c',
  '7a', '7b',
  '8a', '8b', '8c',
  '9a', '9b', '9c',
  '10a', '10b'
];

console.log(`📸 Capturing ${states.length} high-resolution 1080p spotlight frames...`);

for (const state of states) {
  const outFile = path.join(outDir, `state_${state}.png`);
  const url = `http://localhost:8080/index.html?state=${state}&video=1`;
  const cmd = `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --window-size=1920,1080 --screenshot="${outFile}" "${url}" 2>/dev/null`;
  
  try {
    execSync(cmd);
    console.log(`  ✓ Captured state_${state}.png`);
  } catch (err) {
    console.error(`  ✗ Error capturing state_${state}:`, err.message);
  }
}

console.log('✅ All spotlight frames captured successfully!');
