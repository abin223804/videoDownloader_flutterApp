const youtubedl = require('youtube-dl-exec');
const fs = require('fs');
const path = require('path');
const os = require('os');

/**
 * Helper to write cookies to a temp file and return the path, or null if no cookies.
 */
function getCookiesFile() {
    if (process.env.YT_COOKIES) {
        const cookiesPath = path.join(os.tmpdir(), 'yt-cookies.txt');
        fs.writeFileSync(cookiesPath, process.env.YT_COOKIES);
        return cookiesPath;
    }
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
            preferFreeFormats: true,
            referer: url
        };

        const cookiesFile = getCookiesFile();
        if (cookiesFile) options.cookies = cookiesFile;

        const output = await youtubedl(url, options);
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
            noCheckCertificate: true,
        };

        const cookiesFile = getCookiesFile();
        if (cookiesFile) options.cookies = cookiesFile;

        const output = await youtubedl(url, options);
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
