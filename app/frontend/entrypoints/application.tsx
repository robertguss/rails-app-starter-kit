import { createInertiaApp, type ResolvedComponent } from "@inertiajs/react"
import { ThemeProvider } from "next-themes"
import { StrictMode, type ReactNode } from "react"
import { createRoot } from "react-dom/client"

import { AppShell } from "@/components/app-shell"
import { ErrorBoundary } from "@/components/error-boundary"
import { TooltipProvider } from "@/components/ui/tooltip"
import type { SharedPageProps } from "@/types/page"
import "@/styles/application.css"

const pages = import.meta.glob<{ default: ResolvedComponent }>(
  "../pages/**/*.tsx",
)

createInertiaApp<SharedPageProps>({
  title: (title) =>
    title ? `${title} · Rails Starter` : "Rails App Starter Kit",
  resolve: async (name) => {
    const page = pages[`../pages/${name}.tsx`]

    if (!page) {
      throw new Error(`Missing Inertia page: ${name}`)
    }

    const component = (await page()).default
    component.layout ??= (page: ReactNode) => <AppShell>{page}</AppShell>

    return component
  },
  setup({ el, App, props }) {
    createRoot(el).render(
      <StrictMode>
        <ErrorBoundary>
          <ThemeProvider
            attribute="class"
            defaultTheme="system"
            enableSystem
            disableTransitionOnChange
            storageKey="rails-starter-theme"
          >
            <TooltipProvider>
              <App {...props} />
            </TooltipProvider>
          </ThemeProvider>
        </ErrorBoundary>
      </StrictMode>,
    )
  },
})
