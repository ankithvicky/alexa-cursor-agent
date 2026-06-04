const { spawn, execSync } = require('child_process');
const path = require('path');

function resolveWorkdir() {
  const dir = process.env.AGENT_WORKDIR || path.join(process.env.HOME || require('os').homedir(), 'workspace', 'agent');
  return dir;
}

function resolveCursorPath() {
  const home = process.env.HOME || require('os').homedir();
  console.log(`[cursorCli] HOME=${home}`);
  const { existsSync } = require('fs');
  const candidates = [
    `${home}/.local/bin/agent`,
    `${home}/.cursor/bin/agent`,
    '/usr/local/bin/agent',
    '/usr/bin/agent',
  ];
  for (const p of candidates) {
    if (existsSync(p)) return p;
  }
  // Fall back to PATH-based lookup
  const extraPaths = [
    `${home}/.local/bin`,
    `${home}/.cursor/bin`,
    '/usr/local/bin',
    '/usr/bin',
  ];
  for (const dir of extraPaths) {
    if (!process.env.PATH.includes(dir)) {
      process.env.PATH = `${dir}:${process.env.PATH}`;
    }
  }
  try {
    return execSync('which agent', { encoding: 'utf8' }).trim();
  } catch {
    throw new Error(`agent binary not found — checked: ${candidates.join(', ')}`);
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
    ], { cwd: resolveWorkdir() });

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
