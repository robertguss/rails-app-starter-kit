import { Skeleton } from "@/components/ui/skeleton"

export function LoadingState() {
  return (
    <section
      aria-busy="true"
      aria-label="Loading content"
      className="space-y-6 rounded-xl border p-6"
    >
      <div className="flex items-center gap-4">
        <Skeleton className="size-12 rounded-full" />
        <div className="flex-1 space-y-2">
          <Skeleton className="h-4 w-40 max-w-full" />
          <Skeleton className="h-3 w-64 max-w-full" />
        </div>
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {[0, 1, 2].map((item) => (
          <div key={item} className="space-y-3 rounded-lg border p-4">
            <Skeleton className="h-4 w-24" />
            <Skeleton className="h-16 w-full" />
            <Skeleton className="h-3 w-2/3" />
          </div>
        ))}
      </div>
      <span className="sr-only">Loading…</span>
    </section>
  )
}
