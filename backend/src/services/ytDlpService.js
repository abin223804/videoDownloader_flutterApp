const youtubedl = require('youtube-dl-exec');
const fs = require('fs');
const path = require('path');
const os = require('os');

/**
 * Helper to write cookies to a temp file and return the path, or null if no cookies.
 * ENV var takes PRIORITY over the bundled file — easier to refresh without redeploying.
 */
function getCookiesFile() {
    if (process.env.YT_COOKIES) {
        const tempPath = path.join(os.tmpdir(), 'yt-cookies.txt');
        let cookiesContent = process.env.YT_COOKIES;
        // Handle both literal \n and real newlines
        cookiesContent = cookiesContent.replace(/\\n/g, '\n').replace(/\r\n/g, '\n');
        fs.writeFileSync(tempPath, cookiesContent);

        // Log first line only (to confirm format without leaking tokens)
        const firstLine = cookiesContent.split('\n')[0];
        console.log('[ytDlpService] Wrote cookies from ENV. First line:', firstLine);
        console.log('[ytDlpService] Cookie file line count:', cookiesContent.split('\n').filter(l => l.trim()).length);
        return tempPath;
    }

    // Fallback: bundled yt-cookies.txt copied into the Docker image
    const cookiesPath = '/app/yt-cookies.txt';
    if (fs.existsSync(cookiesPath)) {
        console.log('[ytDlpService] Using bundled cookies file at /app/yt-cookies.txt');
        return cookiesPath;
    }

    console.log('[ytDlpService] WARNING: No cookies found. YouTube requests will likely fail.');
    return null;
}

/**
 * Build base yt-dlp options. Tries ios player_client first as it is
 * less aggressive about bot/datacenter detection than android.
 */
function buildBaseOptions(cookiesFile) {
    const options = {
        noWarnings: true,
        noCheckCertificate: true,
        // ios client tends to bypass bot detection better from datacenter IPs
        extractorArgs: 'youtube:player_client=ios,web',
        addHeader: [
            'User-Agent:Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
            'Accept-Language:en-US,en;q=0.9',
        ],
    };

    if (cookiesFile) {
        options.cookies = cookiesFile;
        console.log('[ytDlpService] Using cookies file:', cookiesFile);
    } else {
        console.log('[ytDlpService] No cookies — attempting unauthenticated extraction.');
    }

    return options;
}

/**
 * Extracts metadata for a given URL without downloading.
 * @param {string} url - The URL to extract content from.
 * @returns {Promise<Object>} The metadata object from yt-dlp.
 */
async function extractMetadata(url) {
    const cookiesFile = getCookiesFile();
    const options = {
        ...buildBaseOptions(cookiesFile),
        dumpJson: true,
        preferFreeFormats: true,
    };

    try {
        const youtubedlCustom = youtubedl.create('/usr/local/bin/yt-dlp');
        console.log('[ytDlpService] Extracting metadata for:', url);
        const output = await youtubedlCustom(url, options);
        console.log('[ytDlpService] Extraction successful. Title:', output.title);
        return output;
    } catch (error) {
        const errorMessage =
            error.stderr || error.stdout || error.shortMessage || error.message ||
            (typeof error === 'string' ? error : JSON.stringify(error)) ||
            'Failed to extract metadata';

        console.error(`[ytDlpService] Error extracting metadata for ${url}:`, {
            message: error?.message,
            stderr: error?.stderr,
            stdout: error?.stdout,
            exitCode: error?.exitCode,
        });
        throw new Error(typeof errorMessage === 'string' ? errorMessage.substring(0, 1500) : 'Failed to extract metadata');
    }
}

/**
 * Returns a direct download URL for the requested format.
 * @param {string} url - The URL to extract media from.
 * @param {string} formatId - Optional format ID of the media.
 * @returns {Promise<Object>} Contains the direct download URL.
 */
async function getDownloadUrl(url, formatId = 'best') {
    const cookiesFile = getCookiesFile();
    const options = {
        ...buildBaseOptions(cookiesFile),
        dumpJson: true,
        format: formatId,
    };

    try {
        const youtubedlCustom = youtubedl.create('/usr/local/bin/yt-dlp');
        console.log('[ytDlpService] Getting download URL for:', url, 'format:', formatId);
        const output = await youtubedlCustom(url, options);
        return {
            url: output.url,
            ext: output.ext,
            title: output.title,
        };
    } catch (error) {
        const errorMessage =
            error.stderr || error.stdout || error.shortMessage || error.message ||
            (typeof error === 'string' ? error : JSON.stringify(error)) ||
            'Failed to get direct download stream';

        console.error(`[ytDlpService] Error getting download URL for ${url}:`, {
            message: error?.message,
            stderr: error?.stderr,
            stdout: error?.stdout,
            exitCode: error?.exitCode,
        });
        throw new Error(typeof errorMessage === 'string' ? errorMessage.substring(0, 1500) : 'Failed to get direct download stream');
    }
}

module.exports = {
    extractMetadata,
    getDownloadUrl,
};
