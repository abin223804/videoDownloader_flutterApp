const youtubedl = require('youtube-dl-exec');

/**
 * Extracts metadata for a given URL without downloading.
 * @param {string} url - The URL to extract content from.
 * @returns {Promise<Object>} The metadata object from yt-dlp.
 */
async function extractMetadata(url) {
    try {
        const output = await youtubedl(url, {
            dumpJson: true,
            noWarnings: true,
            noCheckCertificate: true,
            preferFreeFormats: true,
            referer: url
        });
        return output;
    } catch (error) {
        console.error(`Error extracting metadata for ${url}:`, error.stderr || error.message || error);
        throw new Error(error.stderr || error.message || 'Failed to extract metadata');
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
        const output = await youtubedl(url, {
            dumpJson: true,
            format: formatId,
            noWarnings: true,
            noCheckCertificate: true,
        });
        return {
            url: output.url,
            ext: output.ext,
            title: output.title
        };
    } catch (error) {
        console.error(`Error getting download URL for ${url}:`, error.stderr || error.message || error);
        throw new Error('Failed to get direct download stream');
    }
}

module.exports = {
    extractMetadata,
    getDownloadUrl
};
