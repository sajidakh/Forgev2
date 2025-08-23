import { test, expect } from '@playwright/test';

test('@smoke home loads', async ({ page }) => {
  const res = await page.goto('/');
  expect(res?.ok()).toBeTruthy();
  await expect(page.locator('body')).toBeVisible();
});

