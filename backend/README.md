# MediaSaver Pro - Backend

This is the Node.js Express backend for MediaSaver Pro. It utilizes `yt-dlp` to extract media information and download URLs without directly exposing scraping logic on the client device.

## Prerequisites
- Node.js (v18+)
- `yt-dlp` installed and accessible in the system PATH. 
  - On Mac: `brew install yt-dlp`
  - On Ubuntu: `sudo apt install yt-dlp`

## Setup
1. Clone the repository.
2. Run `npm install` inside the `backend/` directory.
3. Copy `.env.example` to `.env` and set your `API_KEY`.
4. Run `node src/index.js` to start the server.

## API Endpoints

All endpoints require the `x-api-key` header for authentication.

### `POST /api/media/extract`
Extracts metadata and available formats for a given URL.

**Body:**
```json
{
  "url": "https://www.youtube.com/watch?v=..."
}
```

**Response:**
```json
{
  "title": "Video Title",
  "thumbnail": "https://...",
  "duration": 120,
  "extractor": "youtube",
  "formats": [...]
}
```

### `POST /api/media/download`
Retrieves the direct stream URL for background downloading on the client.

**Body:**
```json
{
  "url": "https://www.youtube.com/watch?v=...",
  "formatId": "best"
}
```

**Response:**
```json
{
  "url": "https://...",
  "ext": "mp4",
  "title": "Video Title"
}
```

## Deployment Guide (Render / Railway)

1. Create a new Web Service on Render or Railway.
2. Use the repository branch.
3. Set the Root Directory to `backend`.
4. Build Command: `npm install && apt update && apt install -y python3 ffmpeg yt-dlp` (Note: Ensure the runtime has Python/ffmpeg and yt-dlp if it's a Linux container, else use a Dockerfile).
5. Start Command: `node src/index.js`
6. Add the `API_KEY` to Environment Variables.
