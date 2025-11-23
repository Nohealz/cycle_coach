# Apple Music Token Service

Minimal Express server that signs Apple Music developer tokens so the Cycle Coach app can talk to MusicKit without bundling private keys in the mobile build.

## Setup

```bash
cd server
cp .env.example .env
# edit .env with your Team ID, Key ID, and the raw .p8 contents
npm install
npm run dev
```

The service listens on `http://localhost:8787` by default. Production hosts (Render, etc.) will provide `PORT`.

## Endpoints

- `GET /health` → `{ ok: true }`
- `POST /v1/apple-music/token` → `{ token, expiresAt }`

## Deployment

Any Node host works. For Render:

- Root Directory: `server`
- Build Command: `npm install`
- Start Command: `npm start`
- Environment variables: `APPLE_MUSIC_TEAM_ID`, `APPLE_MUSIC_KEY_ID`, `APPLE_MUSIC_PRIVATE_KEY`, optional `APPLE_MUSIC_TOKEN_TTL_SECONDS`, optional `CORS_ORIGIN`.
