import 'dotenv/config.js';
import express from 'express';
import helmet from 'helmet';
import { createAppleMusicToken } from './token.js';

const app = express();
const PORT = process.env.PORT ?? 8787;

app.use(
  helmet({
    crossOriginResourcePolicy: false,
  }),
);

app.get('/health', (_req, res) => {
  res.json({ ok: true, timestamp: new Date().toISOString() });
});

app.post('/v1/apple-music/token', (_req, res) => {
  try {
    const result = createAppleMusicToken();
    res.setHeader('Cache-Control', 'private, max-age=0, must-revalidate');
    res.json(result);
  } catch (error) {
    console.error('Failed to create Apple Music token', error);
    res.status(500).json({ error: 'Unable to create token' });
  }
});

app.listen(PORT, () => {
  console.log(`Apple Music token service listening on :${PORT}`);
});
