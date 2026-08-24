import { Link, usePage } from "@inertiajs/react"
import { BlocksIcon, MenuIcon } from "lucide-react"
import { useState, type ReactNode } from "react"

import { ThemeToggle } from "@/components/theme-toggle"
import { Button } from "@/components/ui/button"
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"
import { cn } from "@/lib/utils"

const navigation = [
  { href: "/", label: "Foundation" },
  { href: "/states/empty", label: "Empty" },
  { href: "/states/loading", label: "Loading" },
  { href: "/health", label: "Health" },
]

function NavigationLink({ href, label }: (typeof navigation)[number]) {
  const { url } = usePage()
  const active = href === "/" ? url === href : url.startsWith(href)

  return (
    <Link
      href={href}
      aria-current={active ? "page" : undefined}
      className={cn(
        "rounded-md px-3 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        active ? "bg-accent text-accent-foreground" : "text-muted-foreground",
      )}
    >
      {label}
    </Link>
  )
}

export function AppShell({ children }: { children: ReactNode }) {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <div className="flex min-h-svh flex-col bg-background">
      <a
        href="#main-content"
        className="sr-only z-50 rounded-md bg-background px-4 py-2 font-medium focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:ring-2 focus:ring-ring"
      >
        Skip to content
      </a>
      <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur supports-backdrop-filter:bg-background/80">
        <div className="mx-auto flex h-16 w-full max-w-6xl items-center gap-3 px-4 sm:px-6 lg:px-8">
          <Link
            href="/"
            className="flex items-center gap-2 font-semibold tracking-tight"
          >
            <span className="grid size-8 place-items-center rounded-lg bg-primary text-primary-foreground">
              <BlocksIcon className="size-4" aria-hidden="true" />
            </span>
            <span>Rails Starter</span>
          </Link>

          <nav
            className="ml-auto hidden items-center gap-1 md:flex"
            aria-label="Primary navigation"
          >
            {navigation.map((item) => (
              <NavigationLink key={item.href} {...item} />
            ))}
          </nav>

          <div className="ml-auto flex items-center gap-1 md:ml-2">
            <ThemeToggle />
            <Sheet open={menuOpen} onOpenChange={setMenuOpen}>
              <SheetTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="md:hidden"
                  aria-label="Open navigation"
                >
                  <MenuIcon />
                </Button>
              </SheetTrigger>
              <SheetContent side="right" className="w-[min(22rem,85vw)]">
                <SheetHeader>
                  <SheetTitle>Rails Starter</SheetTitle>
                  <SheetDescription>
                    Foundation state previews and health.
                  </SheetDescription>
                </SheetHeader>
                <nav
                  className="flex flex-col gap-1 px-4"
                  aria-label="Mobile navigation"
                >
                  {navigation.map((item) => (
                    <SheetClose asChild key={item.href}>
                      <NavigationLink {...item} />
                    </SheetClose>
                  ))}
                </nav>
              </SheetContent>
            </Sheet>
          </div>
        </div>
      </header>

      <main id="main-content" className="flex-1">
        {children}
      </main>

      <footer className="border-t">
        <div className="mx-auto flex w-full max-w-6xl flex-col gap-1 px-4 py-6 text-sm text-muted-foreground sm:px-6 md:flex-row md:items-center md:justify-between lg:px-8">
          <p>Application-owned Rails, React, and PostgreSQL.</p>
          <p>No hosted provider or production Node process required.</p>
        </div>
      </footer>
    </div>
  )
}
