const ytDlpService = require('./src/services/ytDlpService');
async function test() {
    try {
        await ytDlpService.extractMetadata("https://youtube.com/shorts/caZA870EVYo?si=rYizpvGyOGMsXqIo");
    } catch (e) {
        console.error("RAW ERROR TYPE:", typeof e);
        console.error("RAW ERROR is Error?", e instanceof Error);
        console.error("RAW ERROR properties:", Object.getOwnPropertyNames(e));
        console.error("RAW ERROR toString:", e.toString());
        console.error("RAW ERROR JSON:", JSON.stringify(e));
    }
}
test();
