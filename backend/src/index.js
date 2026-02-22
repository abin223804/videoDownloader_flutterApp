const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');

dotenv.config();

// yt-dlp requires Python >= 3.10. We prepend Homebrew Python 3.11 to the path.
process.env.PATH = '/opt/homebrew/opt/python@3.11/libexec/bin:/usr/local/opt/python@3.11/libexec/bin:' + process.env.PATH;

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(helmet());
app.use(express.json());

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes)
  message: 'Too many requests from this IP, please try again after 15 minutes',
});

// Basic API Key Security Middleware
const apiKeyAuth = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey || apiKey !== process.env.API_KEY) {
    return res.status(401).json({ error: 'Unauthorized: Invalid API Key' });
  }
  next();
};

app.use('/api', apiLimiter);

// Routes
const mediaRoutes = require('./routes/media');
app.use('/api/media', apiKeyAuth, mediaRoutes);

app.get('/', (req, res) => {
  res.status(200).json({ message: 'MediaSaver Pro  is running' });
});

app.get('/api/debug/version', (req, res) => {
  const { exec } = require('child_process');
  exec('/usr/local/bin/yt-dlp --version', (error, stdout, stderr) => {
    if (error) {
      return res.status(500).json({ error: error.message, stderr });
    }
    res.status(200).json({ version: stdout.trim() });
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.listen(port, () => {
  console.log(`MediaSaver Pro Backend listening at http://localhost:${port}`);
});
