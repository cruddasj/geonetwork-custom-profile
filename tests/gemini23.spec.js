const { test, expect } = require('@playwright/test');

async function loginAsAdmin(page) {
  await page.goto('/geonetwork');

  const loginLink = page.getByRole('link', { name: /sign in|login/i });
  if (await loginLink.count()) {
    await loginLink.first().click();
  }

  await page.locator('input[name="username"], input#username').first().fill('admin');
  await page.locator('input[name="password"], input#password').first().fill('admin');

  const submit = page.getByRole('button', { name: /sign in|login/i });
  if (await submit.count()) {
    await submit.first().click();
  } else {
    await page.keyboard.press('Enter');
  }

  await expect(page.getByText(/admin/i).first()).toBeVisible();
}

test('admin can access metadata/templates and GEMINI 2.3 schema is listed', async ({ page, context }) => {
  await loginAsAdmin(page);

  await page.goto('/geonetwork/srv/eng/admin.console#/metadata');

  await expect(page.getByText(/metadata\s*&\s*templates/i)).toBeVisible();
  await expect(page.getByText('iso19139.gemini23')).toBeVisible();

  const response = await context.request.get('/geonetwork/srv/api/schemas');
  expect(response.ok()).toBeTruthy();
  const schemas = await response.json();

  const hasGemini = Array.isArray(schemas)
    ? schemas.some((schema) => String(schema?.name || schema?.id || '').includes('iso19139.gemini23'))
    : String(JSON.stringify(schemas)).includes('iso19139.gemini23');

  expect(hasGemini).toBeTruthy();
});
