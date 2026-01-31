// Generic VR bug test: load page, take screenshot, check for console errors
const { chromium } = require('playwright-chromium');

async function testBug(url, screenshotPath) {
    const browser = await chromium.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-gpu']
    });

    const page = await browser.newPage();
    const consoleErrors = [];

    // Collect console errors
    page.on('console', msg => {
        if (msg.type() === 'error') {
            consoleErrors.push(msg.text());
        }
    });

    // Collect page errors
    const pageErrors = [];
    page.on('pageerror', err => {
        pageErrors.push(err.message);
    });

    try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });

        // Wait for A-Frame/three.js to render
        await page.waitForTimeout(3000);

        // Take screenshot
        await page.screenshot({ path: screenshotPath, fullPage: true });

        console.log(`Screenshot saved: ${screenshotPath}`);
        console.log(`Console errors: ${consoleErrors.length}`);
        console.log(`Page errors: ${pageErrors.length}`);

        if (consoleErrors.length > 0) {
            console.log('Console errors:');
            consoleErrors.forEach(e => console.log(`  - ${e}`));
        }
        if (pageErrors.length > 0) {
            console.log('Page errors:');
            pageErrors.forEach(e => console.log(`  - ${e}`));
        }

        await browser.close();

        // Exit with error if there were JS errors
        if (pageErrors.length > 0) {
            process.exit(1);
        }
        process.exit(0);

    } catch (err) {
        console.error(`Test failed: ${err.message}`);
        await browser.close();
        process.exit(1);
    }
}

const url = process.argv[2] || 'http://localhost:8080';
const screenshot = process.argv[3] || 'screenshot.png';
testBug(url, screenshot);
