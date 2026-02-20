const express = require('express');
const router = express.Router();
const ytDlpService = require('../services/ytDlpService');

// POST /api/media/extract
router.post('/extract', async (req, res) => {
    const { url } = req.body;
    if (!url) {
        return res.status(400).json({ error: 'URL is required' });
    }

    try {
        const metadata = await ytDlpService.extractMetadata(url);

        // Pick the most relevant information to reduce payload size
        const responseData = {
            title: metadata.title,
            thumbnail: metadata.thumbnail,
            duration: metadata.duration,
            extractor: metadata.extractor,
            formats: metadata.formats
                .filter(f => f.protocol === 'https' && f.url && f.ext !== 'mhtml')
                .map(f => ({
                    format_id: f.format_id,
                    ext: f.ext,
                    resolution: f.resolution || (f.width ? `${f.width}x${f.height}` : 'Audio'),
                    filesize: f.filesize || f.filesize_approx,
                    vcodec: f.vcodec,
                    acodec: f.acodec,
                })),
        };

        res.json(responseData);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST /api/media/download
router.post('/download', async (req, res) => {
    const { url, formatId } = req.body;
    if (!url) {
        return res.status(400).json({ error: 'URL is required' });
    }

    try {
        const downloadInfo = await ytDlpService.getDownloadUrl(url, formatId);
        // the direct url is returned so flutter can download it natively in the background.
        // This removes the need for GET /progress on the server side because flutter_downloader 
        // will track progress directly on the device!
        res.json(downloadInfo);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
