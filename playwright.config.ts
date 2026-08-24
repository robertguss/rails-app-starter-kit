import { defineConfig } from "@playwright/test"

export default defineConfig({
  testDir: "./test/browser",
  fullyParallel: false,
  reporter: "line",
  use: {
    baseURL: "http://127.0.0.1:3101",
    trace: "retain-on-failure",
  },
  webServer: {
    command: "RAILS_ENV=test bin/rails server --binding 127.0.0.1 --port 3101",
    url: "http://127.0.0.1:3101/up",
    reuseExistingServer: false,
    timeout: 120_000,
  },
})
