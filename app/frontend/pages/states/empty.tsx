import { Head, Link } from "@inertiajs/react"

import { EmptyState } from "@/components/states/empty-state"
import { Button } from "@/components/ui/button"

export default function EmptyPage() {
  return (
    <>
      <Head title="Empty state" />
      <div className="mx-auto w-full max-w-4xl px-4 py-10 sm:px-6 sm:py-16 lg:px-8">
        <header className="mb-8">
          <p className="text-sm font-medium text-muted-foreground">
            Representative UI
          </p>
          <h1 className="mt-2 text-3xl font-semibold tracking-tight">
            Empty state
          </h1>
          <p className="mt-3 max-w-2xl text-muted-foreground">
            Empty screens should explain what belongs here and offer the next
            useful action without inventing data.
          </p>
        </header>
        <EmptyState
          title="Nothing here yet"
          description="This application has a clean foundation and no product records. Add the first workflow only when the application needs it."
          action={
            <Button asChild variant="outline">
              <Link href="/">Return to the foundation</Link>
            </Button>
          }
        />
      </div>
    </>
  )
}
