// test.spec.js

const { test, expect, chromium } = require('@playwright/test');

test('should perform Google search by pasting query and decline cookies', async () => {
  // Connect to the remote Chrome instance over CDP
  const browser = await chromium.connectOverCDP('http://localhost:9223');

  // Create a new context with clipboard permissions
  const context = await browser.newContext({
    permissions: ['clipboard-read', 'clipboard-write'],
    // Run in headful mode if needed
    // headless: false,
  });
  const page = await context.newPage();

  // Navigate to Google
  await page.goto('https://www.google.com');

  // Handle the cookies consent dialog
  try {
    // Attempt to click 'Decline all' button
    await page.getByRole('button', { name: /^Decline all$/i }).click({ timeout: 5000 });
  } catch (e) {
    try {
      // If 'Decline all' is not present, try 'Reject all'
      await page.getByRole('button', { name: /^Reject all$/i }).click({ timeout: 5000 });
    } catch (e) {
      try {
        // If neither, click 'Customize' and then 'Reject all'
        await page.getByRole('button', { name: /^Customize$/i }).click({ timeout: 5000 });
        await page.getByRole('button', { name: /^Reject all$/i }).click({ timeout: 5000 });
      } catch (e) {
        // Continue if no dialog is present
      }
    }
  }

  // Define the search query
  const searchQuery = 'playwright testing';

  // Set the clipboard content to the search query
  try {
    await page.evaluate(async (text) => {
      await navigator.clipboard.writeText(text);
    }, searchQuery);
  } catch (e) {
    console.error('Clipboard write failed:', e);
  }

  // Focus on the search input field
  const searchInput = page.locator('input[name="q"]');
  await searchInput.click();

  // Paste the clipboard content into the search field
  // Use 'Control+V' for Windows/Linux and 'Meta+V' for macOS
  await page.keyboard.press(process.platform === 'darwin' ? 'Meta+V' : 'Control+V');

  // Press 'Enter' to perform the search
  await page.keyboard.press('Enter');

  // Verify that the search results appeared
  await expect(page.locator('#search')).toBeVisible();

  // Wait a bit to see the results (optional)
  await page.waitForTimeout(2000);

  // Close the context and browser
  await context.close();
  await browser.close();
});