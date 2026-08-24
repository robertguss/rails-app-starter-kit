import { Head, Link, useForm } from "@inertiajs/react"
import {
  ArrowRightIcon,
  CheckCircle2Icon,
  DatabaseIcon,
  Layers3Icon,
  ServerIcon,
  SparklesIcon,
} from "lucide-react"
import type { FormEvent } from "react"

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"

interface HomePageProps {
  flash: {
    alert?: string
    notice?: string
  }
  versions: {
    inertia: string
    rails: string
    ruby: string
  }
}

interface RoundTripForm {
  message: string
}

const foundationStates = [
  {
    href: "/states/empty",
    label: "Empty",
    description: "A quiet starting point with one clear action.",
  },
  {
    href: "/states/loading",
    label: "Loading",
    description: "Stable skeletons with an accessible busy state.",
  },
  {
    href: "/health",
    label: "Health",
    description: "Human-readable application and database status.",
  },
  {
    href: "/missing-page",
    label: "404",
    description: "An Inertia response inside the same application shell.",
  },
]

export default function HomePage({ flash, versions }: HomePageProps) {
  const form = useForm<RoundTripForm>({ message: "" })

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    form.transform((data) => ({ round_trip_message: data }))
    form.post("/round_trip_messages", {
      preserveScroll: true,
      onSuccess: () => form.reset(),
    })
  }

  return (
    <>
      <Head title="Foundation" />
      <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 sm:py-14 lg:px-8 lg:py-20">
        <section className="grid items-center gap-10 lg:grid-cols-[1.2fr_0.8fr] lg:gap-14">
          <div>
            <div className="mb-5 flex flex-wrap gap-2">
              <Badge variant="secondary">Phase 1</Badge>
              <Badge variant="outline">Provider neutral</Badge>
              <Badge variant="outline">Client rendered</Badge>
            </div>
            <h1 className="max-w-3xl text-4xl font-semibold tracking-tight text-balance sm:text-5xl lg:text-6xl">
              A boring foundation for useful Rails applications.
            </h1>
            <p className="mt-6 max-w-2xl text-lg leading-8 text-pretty text-muted-foreground">
              Rails owns routing, validation, data, and HTTP. React supplies
              rich pages through Inertia, while PostgreSQL keeps the durable
              center application-owned.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Button asChild>
                <Link href="/health">
                  Check the foundation
                  <ArrowRightIcon />
                </Link>
              </Button>
              <Button variant="outline" asChild>
                <Link href="/states/empty">View interface states</Link>
              </Button>
            </div>
          </div>

          <Card className="shadow-lg shadow-black/5">
            <CardHeader>
              <div className="mb-2 grid size-10 place-items-center rounded-lg bg-primary text-primary-foreground">
                <SparklesIcon className="size-4" aria-hidden="true" />
              </div>
              <CardTitle>Try the Inertia round trip</CardTitle>
              <CardDescription>
                Submit a message. Rails validates it and redirects with errors
                or a flash response.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {flash.notice ? (
                <Alert className="mb-5 border-emerald-500/30 bg-emerald-500/5 text-emerald-950 dark:text-emerald-100">
                  <CheckCircle2Icon />
                  <AlertTitle>Round trip complete</AlertTitle>
                  <AlertDescription>{flash.notice}</AlertDescription>
                </Alert>
              ) : null}
              <form onSubmit={submit} className="space-y-4" noValidate>
                <div className="space-y-2">
                  <Label htmlFor="round-trip-message">Message</Label>
                  <Textarea
                    id="round-trip-message"
                    name="message"
                    value={form.data.message}
                    onChange={(event) =>
                      form.setData("message", event.target.value)
                    }
                    placeholder="Rails and React, without a separate API"
                    maxLength={120}
                    aria-invalid={Boolean(form.errors.message)}
                    aria-describedby={
                      form.errors.message
                        ? "round-trip-message-error"
                        : undefined
                    }
                  />
                  {form.errors.message ? (
                    <p
                      id="round-trip-message-error"
                      className="text-sm text-destructive"
                      role="alert"
                    >
                      {form.errors.message}
                    </p>
                  ) : (
                    <p className="text-xs text-muted-foreground">
                      Server validation is the source of truth.
                    </p>
                  )}
                </div>
                <Button
                  type="submit"
                  disabled={form.processing}
                  className="w-full sm:w-auto"
                >
                  {form.processing ? "Sending…" : "Send through Rails"}
                </Button>
              </form>
            </CardContent>
          </Card>
        </section>

        <section
          className="mt-16 border-t pt-12 sm:mt-20 sm:pt-16"
          aria-labelledby="stack-heading"
        >
          <div className="max-w-2xl">
            <p className="text-sm font-medium text-muted-foreground">
              One deployable application
            </p>
            <h2
              id="stack-heading"
              className="mt-2 text-2xl font-semibold tracking-tight sm:text-3xl"
            >
              Clear ownership at every layer
            </h2>
          </div>
          <div className="mt-7 grid gap-4 md:grid-cols-3">
            <FoundationCard
              icon={<ServerIcon />}
              title={`Rails ${versions.rails} · Ruby ${versions.ruby}`}
              description="Controllers render explicit Inertia props and ordinary Rails redirects."
            />
            <FoundationCard
              icon={<Layers3Icon />}
              title={`Inertia Rails ${versions.inertia}`}
              description="React 19 and TypeScript live under one app/frontend root, with no production SSR."
            />
            <FoundationCard
              icon={<DatabaseIcon />}
              title="PostgreSQL"
              description="Future product invariants belong in migrations, foreign keys, indexes, and constraints."
            />
          </div>
        </section>

        <section className="mt-16 sm:mt-20" aria-labelledby="states-heading">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-sm font-medium text-muted-foreground">
                Representative UI
              </p>
              <h2
                id="states-heading"
                className="mt-2 text-2xl font-semibold tracking-tight sm:text-3xl"
              >
                Foundation states
              </h2>
            </div>
            <p className="max-w-lg text-sm leading-6 text-muted-foreground">
              Each state stays responsive, theme-aware, and inside the same
              accessible shell.
            </p>
          </div>
          <div className="mt-7 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {foundationStates.map((state) => (
              <Link
                key={state.href}
                href={state.href}
                className="group rounded-xl border bg-card p-5 transition-colors hover:border-foreground/20 hover:bg-accent/50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                <div className="flex items-center justify-between gap-3">
                  <h3 className="font-semibold">{state.label}</h3>
                  <ArrowRightIcon className="size-4 text-muted-foreground transition-transform group-hover:translate-x-1" />
                </div>
                <p className="mt-3 text-sm leading-6 text-muted-foreground">
                  {state.description}
                </p>
              </Link>
            ))}
          </div>
        </section>
      </div>
    </>
  )
}

function FoundationCard({
  description,
  icon,
  title,
}: {
  description: string
  icon: React.ReactNode
  title: string
}) {
  return (
    <Card className="gap-4 shadow-none">
      <CardHeader>
        <span className="mb-3 grid size-9 place-items-center rounded-md bg-muted text-foreground [&_svg]:size-4">
          {icon}
        </span>
        <CardTitle className="text-base">{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-sm leading-6 text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  )
}
