const youtubedl = require('youtube-dl-exec');
const fs = require('fs');
const path = require('path');
const os = require('os');

/**
 * Helper to write cookies to a temp file and return the path, or null if no cookies.
 */
function getCookiesFile() {
    console.log('[ytDlpService] Docker Workdir:', process.cwd());
    console.log('[ytDlpService] __dirname:', __dirname);
    try {
        console.log('[ytDlpService] Files in /app:', fs.readdirSync('/app'));
    } catch (e) { }

    // Explicitly check /app/yt-cookies.txt since Dockerfile sets WORKDIR /app and COPY . .
    const cookiesPath = '/app/yt-cookies.txt';
    console.log('[ytDlpService] Checking for cookies file at:', cookiesPath);
    if (fs.existsSync(cookiesPath)) {
        console.log('[ytDlpService] Found bundled cookies file at /app/yt-cookies.txt!');
        return cookiesPath;
    }

    console.log('[ytDlpService] Bundled cookies file NOT found in /app. Checking ENV...');
    if (process.env.YT_COOKIES) {
        const tempPath = path.join(os.tmpdir(), 'yt-cookies.txt');
        let cookiesContent = process.env.YT_COOKIES;
        cookiesContent = cookiesContent.replace(/\\n/g, '\n').replace(/\r\n/g, '\n');
        fs.writeFileSync(tempPath, cookiesContent);
        console.log('[ytDlpService] Wrote cookies from ENV to:', tempPath);
        return tempPath;
    }
    console.log('[ytDlpService] No cookies found anywhere.');
    return null;
}

/**
 * Extracts metadata for a given URL without downloading.
 * @param {string} url - The URL to extract content from.
 * @returns {Promise<Object>} The metadata object from yt-dlp.
 */
async function extractMetadata(url) {
    try {
        const options = {
            dumpJson: true,
            noWarnings: true,
            noCheckCertificate: true,
            preferFreeFormats: true
        };

        const cookiesFile = getCookiesFile();
        if (cookiesFile) options.cookies = cookiesFile;

        const youtubedlCustom = youtubedl.create('/usr/local/bin/yt-dlp');
        const output = await youtubedlCustom(url, options);
        return output;
    } catch (error) {
        // tinyspawn/execa errors have stdout, stderr, shortMessage, message, exitCode
        const errorMessage = error.stderr || error.stdout || error.shortMessage || error.message || (typeof error === 'string' ? error : JSON.stringify(error)) || 'Failed to extract metadata';
        console.error(`Error extracting metadata for ${url}:`, {
            rawError: error,
            message: error?.message,
            stderr: error?.stderr,
            stdout: error?.stdout,
            exitCode: error?.exitCode
        });
        throw new Error(typeof errorMessage === 'string' ? errorMessage.substring(0, 1000) : 'Failed to extract metadata');
    }
}

/**
 * Initiates the download but returns a direct stream URL 
 * to handle it directly on the client if preferred, or configures background download.
 * We will return the best format URL to offload actual downloading to Flutter's flutter_downloader.
 * @param {string} url - The URL to extract media from.
 * @param {string} formatId - Optional format ID of the media.
 * @returns {Promise<Object>} Contains the direct download URL.
 */
async function getDownloadUrl(url, formatId = 'best') {
    try {
        const options = {
            dumpJson: true,
            format: formatId,
            noWarnings: true,
            noCheckCertificate: true
        };

        const cookiesFile = getCookiesFile();
        if (cookiesFile) options.cookies = cookiesFile;

        const youtubedlCustom = youtubedl.create('/usr/local/bin/yt-dlp');
        const output = await youtubedlCustom(url, options);
        return {
            url: output.url,
            ext: output.ext,
            title: output.title
        };
    } catch (error) {
        const errorMessage = error.stderr || error.stdout || error.shortMessage || error.message || (typeof error === 'string' ? error : JSON.stringify(error)) || 'Failed to get direct download stream';
        console.error(`Error getting download URL for ${url}:`, {
            rawError: error,
            message: error?.message,
            stderr: error?.stderr,
            stdout: error?.stdout,
            exitCode: error?.exitCode
        });
        throw new Error(typeof errorMessage === 'string' ? errorMessage.substring(0, 1000) : 'Failed to get direct download stream');
    }
}

module.exports = {
    extractMetadata,
    getDownloadUrl
};
