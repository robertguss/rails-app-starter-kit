import { expect, test } from "@playwright/test"

test("closed access redirects to an honest method-aware login", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 })
  await page.goto("/")

  await expect(page).toHaveURL(/\/login\?return_to=%2F$/)
  await expect(page.getByRole("heading", { name: "Sign in" })).toBeVisible()
  await expect(page.getByLabel("Email")).toBeVisible()
  await expect(page.getByLabel("Password")).toBeVisible()
  await expect(
    page.getByRole("link", { name: "Forgot password?" }),
  ).toBeVisible()
  expect(
    await page.evaluate(
      () =>
        document.documentElement.scrollWidth <=
        document.documentElement.clientWidth,
    ),
  ).toBe(true)
})

test("owner agent access exposes access administration and sign out", async ({
  page,
}) => {
  const response = await page.request.post("/agent/login", {
    form: { user: "owner", return_to: "/settings/access" },
  })
  expect(response.ok()).toBe(true)

  await page.goto("/settings/access")
  await expect(page.getByRole("heading", { name: "Access" })).toBeVisible()
  await expect(page.getByText("owner@example.test")).toBeVisible()
  await expect(page.getByRole("link", { name: "Access" })).toBeVisible()
  await expect(page.getByRole("button", { name: "Sign out" })).toBeVisible()
})

test("agent access rejects arbitrary identities", async ({ request }) => {
  const response = await request.post("/agent/login", {
    form: { user: "arbitrary@example.test" },
    maxRedirects: 0,
  })

  expect(response.status()).toBe(404)
})
