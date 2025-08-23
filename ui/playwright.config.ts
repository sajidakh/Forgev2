import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  reporter: [['html', { open: 'never' }], ['line']],
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
  },
  // Start preview server without npm/npx wrappers
  webServer: {
    command: 'node ./node_modules/vite/bin/vite.js preview --strictPort --port=5173',
    port: 5173,
    reuseExistingServer: true,
    timeout: 60 * 1000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
