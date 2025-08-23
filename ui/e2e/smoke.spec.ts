import { test, expect } from '@playwright/test';

test('@smoke app loads home', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/vite/i);
});
