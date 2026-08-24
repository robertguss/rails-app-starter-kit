import { Head } from "@inertiajs/react"

import { LoadingState } from "@/components/states/loading-state"

export default function LoadingPage() {
  return (
    <>
      <Head title="Loading state" />
      <div className="mx-auto w-full max-w-4xl px-4 py-10 sm:px-6 sm:py-16 lg:px-8">
        <header className="mb-8">
          <p className="text-sm font-medium text-muted-foreground">
            Representative UI
          </p>
          <h1 className="mt-2 text-3xl font-semibold tracking-tight">
            Loading state
          </h1>
          <p className="mt-3 max-w-2xl text-muted-foreground">
            The layout stays stable while remote work completes, and assistive
            technology receives a clear busy signal.
          </p>
        </header>
        <LoadingState />
      </div>
    </>
  )
}
