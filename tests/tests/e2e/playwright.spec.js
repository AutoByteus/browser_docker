// test.spec.js

const { test, expect, chromium } = require('@playwright/test');

test('should navigate to Playwright site and verify the title', async () => {
  // Connect to the remote Chrome instance over CDP
  const browser = await chromium.connectOverCDP('http://localhost:9223');

  // Create a new context and page
  const context = await browser.newContext();
  const page = await context.newPage();

  // Navigate to the Playwright website
  await page.goto('https://playwright.dev');

  // Verify that the title contains "Playwright"
  await expect(page).toHaveTitle(/Playwright/);

  // Optionally, you can perform more checks, like verifying the presence of a specific element
  await expect(page.locator('text=Get Started')).toBeVisible();

  // Close the context and browser
  await context.close();
  await browser.close();
});