import { Link } from "@inertiajs/react"
import { CircleAlertIcon } from "lucide-react"

import { Button } from "@/components/ui/button"

export function ErrorState({
  code,
  description,
  title,
}: {
  code: string
  description: string
  title: string
}) {
  return (
    <section className="flex min-h-[60svh] flex-col items-center justify-center px-4 py-16 text-center">
      <span className="mb-5 grid size-14 place-items-center rounded-full bg-destructive/10 text-destructive">
        <CircleAlertIcon className="size-6" aria-hidden="true" />
      </span>
      <p className="text-sm font-semibold tracking-widest text-muted-foreground uppercase">
        Error {code}
      </p>
      <h1 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">
        {title}
      </h1>
      <p className="mt-4 max-w-lg text-pretty text-muted-foreground">
        {description}
      </p>
      <Button asChild className="mt-7">
        <Link href="/">Return to the foundation</Link>
      </Button>
    </section>
  )
}
