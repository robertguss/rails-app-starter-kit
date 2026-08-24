import inertia from "@inertiajs/vite"
import tailwindcss from "@tailwindcss/vite"
import react from "@vitejs/plugin-react"
import { fileURLToPath, URL } from "node:url"
import RubyPlugin from "vite-plugin-ruby"
import { defineConfig } from "vitest/config"

export default defineConfig({
  plugins: [
    RubyPlugin(),
    inertia(),
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./app/frontend", import.meta.url)),
    },
  },
  test: {
    environment: "jsdom",
    setupFiles: ["./test/setup.ts"],
  },
})
