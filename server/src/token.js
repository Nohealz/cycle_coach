import jwt from 'jsonwebtoken';
import fs from 'node:fs';

const TEAM_ID = process.env.APPLE_MUSIC_TEAM_ID;
const KEY_ID = process.env.APPLE_MUSIC_KEY_ID;
const TOKEN_TTL_SECONDS = Number(
  process.env.APPLE_MUSIC_TOKEN_TTL_SECONDS ?? 60 * 60 * 24 * 7,
);

let cachedToken = null;
let cachedExpiry = 0;

function getPrivateKey() {
  if (process.env.APPLE_MUSIC_PRIVATE_KEY) {
    return process.env.APPLE_MUSIC_PRIVATE_KEY.replace(/\\n/g, '\n');
  }
  if (process.env.APPLE_MUSIC_PRIVATE_KEY_PATH) {
    return fs.readFileSync(process.env.APPLE_MUSIC_PRIVATE_KEY_PATH, 'utf8');
  }
  throw new Error('APPLE_MUSIC_PRIVATE_KEY or _PATH must be provided');
}

export function createAppleMusicToken() {
  if (!TEAM_ID || !KEY_ID) {
    throw new Error('Missing Apple Music environment variables');
  }

  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && now < cachedExpiry - 60) {
    return {
      token: cachedToken,
      expiresAt: new Date(cachedExpiry * 1000).toISOString(),
    };
  }

const payload = {
  iss: TEAM_ID,
  iat: now,
  exp: now + TOKEN_TTL_SECONDS,
  // Apple Music requires only iss/iat/exp; no bid/aud/extra claims.
};

  const privateKey = getPrivateKey();
  const token = jwt.sign(payload, privateKey, {
    algorithm: 'ES256',
    keyid: KEY_ID,
  });

  cachedToken = token;
  cachedExpiry = payload.exp;

  return { token, expiresAt: new Date(payload.exp * 1000).toISOString() };
}
