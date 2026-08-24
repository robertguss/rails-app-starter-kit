import { expect, test } from "@playwright/test"

test("Inertia navigation and Rails form validation complete without a full-page API layer", async ({
  page,
}) => {
  await page.goto("/")

  await page.getByRole("button", { name: "Send through Rails" }).click()
  await expect(page.getByRole("alert")).toContainText("can't be blank")

  await page.getByLabel("Message").fill("Hello from Playwright")
  await page.getByRole("button", { name: "Send through Rails" }).click()
  await expect(page.getByText("Round trip complete")).toBeVisible()
  await expect(page.getByRole("alert")).toContainText(
    "Rails received “Hello from Playwright” through Inertia.",
  )

  const inertiaRequest = page.waitForRequest((request) =>
    request.url().endsWith("/states/empty"),
  )
  await page.getByRole("link", { name: "View interface states" }).click()
  expect((await inertiaRequest).headers()["x-inertia"]).toBe("true")
  await expect(page.getByRole("heading", { name: "Empty state" })).toBeVisible()
})

for (const viewport of [
  { name: "phone", width: 390, height: 844 },
  { name: "tablet", width: 768, height: 1024 },
  { name: "desktop", width: 1440, height: 1000 },
]) {
  test(`responsive shell at ${viewport.name} size`, async ({ page }) => {
    await page.setViewportSize({
      width: viewport.width,
      height: viewport.height,
    })
    await page.goto("/")

    await expect(
      page.getByRole("heading", {
        name: "A boring foundation for useful Rails applications.",
      }),
    ).toBeVisible()
    expect(
      await page.evaluate(
        () =>
          document.documentElement.scrollWidth <=
          document.documentElement.clientWidth,
      ),
    ).toBe(true)

    const mobileMenu = page.getByRole("button", { name: "Open navigation" })
    const desktopNavigation = page.getByRole("navigation", {
      name: "Primary navigation",
    })

    if (viewport.width < 768) {
      await expect(mobileMenu).toBeVisible()
      await expect(desktopNavigation).toBeHidden()
      await mobileMenu.click()
      await expect(
        page.getByRole("navigation", { name: "Mobile navigation" }),
      ).toBeVisible()
    } else {
      await expect(mobileMenu).toBeHidden()
      await expect(desktopNavigation).toBeVisible()
    }
  })
}

test("dark mode and representative states remain usable", async ({ page }) => {
  await page.goto("/")
  await page.getByRole("button", { name: "Change color theme" }).click()
  await page.getByRole("menuitem", { name: "Dark" }).click()
  await expect(page.locator("html")).toHaveClass(/dark/)
  await page.reload()
  await expect(page.locator("html")).toHaveClass(/dark/)

  await page.goto("/states/loading")
  await expect(page.getByLabel("Loading content")).toHaveAttribute(
    "aria-busy",
    "true",
  )

  await page.goto("/health")
  await expect(
    page.getByText("All foundation checks are healthy"),
  ).toBeVisible()

  const notFound = await page.goto("/missing-browser-page")
  expect(notFound?.status()).toBe(404)
  await expect(
    page.getByRole("heading", { name: "That page does not exist" }),
  ).toBeVisible()

  const applicationError = page.waitForResponse((response) =>
    response.url().endsWith("/500"),
  )
  await page.locator("body").evaluate((body) => {
    const form = document.createElement("form")
    form.action = "/500"
    form.method = "post"
    body.append(form)
    form.submit()
  })
  expect((await applicationError).status()).toBe(500)
  await expect(
    page.getByRole("heading", {
      name: "The application could not complete that request",
    }),
  ).toBeVisible()
})
