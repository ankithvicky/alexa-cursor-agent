const { spawn, execSync } = require('child_process');

function resolveCursorPath() {
  if (process.env.CURSOR_CLI_PATH) return process.env.CURSOR_CLI_PATH;
  try {
    return execSync('which agent', { encoding: 'utf8' }).trim();
  } catch {
    throw new Error('agent binary not found — set CURSOR_CLI_PATH or ensure agent is on PATH');
  }
}

async function askCursor(context, query) {
  // Build full prompt with instructions and context
  let fullPrompt = process.env.RESPONSE_INSTRUCTIONS + '\n\n';

  if (context) {
    fullPrompt += context + '\n\n';
  }

  fullPrompt += `Current question: ${query}`;

  return new Promise((resolve, reject) => {
    // Spawn cursor agent command
    const cursor = spawn(resolveCursorPath(), [
      '-p',
      '--yolo',
      '--output-format', 'text',
      fullPrompt
    ]);

    let output = '';
    let errorOutput = '';

    cursor.stdout.on('data', (data) => { output += data.toString(); });
    cursor.stderr.on('data', (data) => { errorOutput += data.toString(); });

    cursor.on('close', (code) => {
      if (code === 0) {
        resolve(output.trim());
      } else {
        reject(new Error(`Cursor CLI failed: ${errorOutput}`));
      }
    });

    cursor.on('error', (err) => {
      reject(new Error(`Failed to spawn Cursor CLI: ${err.message}`));
    });

    // Timeout after 4 minutes
    const timeout = setTimeout(() => {
      cursor.kill();
      reject(new Error('Cursor CLI timeout'));
    }, 240000);

    cursor.on('close', () => clearTimeout(timeout));
  });
}

module.exports = { askCursor };
