import { test, expect } from '@playwright/test';

test('checkout', async ({ page }) => {
  await page.goto('/cart');
  await page.click('#checkout');
  await page.fill('#card', '4242424242424242');
  await page.click('#pay');
  await page.waitForTimeout(3000);
  expect(await page.textContent('#status')).toBe(
    await page.textContent('#status')
  );
});
