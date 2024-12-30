// playwright.config.js

const { defineConfig } = require('@playwright/test');


// Directly connecting over  CDP in playwright test, no need to add global endpoint
module.exports = defineConfig({
  timeout: 30000,
  use: {
  },
});