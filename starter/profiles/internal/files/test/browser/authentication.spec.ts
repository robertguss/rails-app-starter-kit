import { expect, test } from "@playwright/test"

test("closed access exposes only the configured workspace sign-in", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 })
  await page.goto("/")

  await expect(page).toHaveURL(/\/login\?return_to=%2F$/)
  await expect(page.getByRole("heading", { name: "Sign in" })).toBeVisible()
  await expect(
    page.getByRole("button", { name: "Continue with Google" }),
  ).toBeVisible()
  await expect(page.getByLabel("Password")).toHaveCount(0)
  expect(
    await page.evaluate(
      () =>
        document.documentElement.scrollWidth <=
        document.documentElement.clientWidth,
    ),
  ).toBe(true)
})

test("owner agent access exposes access administration", async ({ page }) => {
  const response = await page.request.post("/agent/login", {
    form: { user: "owner", return_to: "/settings/access" },
  })
  expect(response.ok()).toBe(true)
  await page.goto("/settings/access")
  await expect(page.getByRole("heading", { name: "Access" })).toBeVisible()
  await expect(page.getByText("owner@example.test")).toBeVisible()
})
