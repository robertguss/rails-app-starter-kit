import { Head } from "@inertiajs/react"
import {
  CheckCircle2Icon,
  CircleAlertIcon,
  ExternalLinkIcon,
  HeartPulseIcon,
} from "lucide-react"

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Badge } from "@/components/ui/badge"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"

interface HealthPageProps {
  checks: {
    application: "ok" | "unavailable"
    database: "ok" | "unavailable"
  }
  status: "ok" | "degraded"
}

export default function HealthPage({ checks, status }: HealthPageProps) {
  const healthy = status === "ok"

  return (
    <>
      <Head title="Health" />
      <div className="mx-auto w-full max-w-4xl px-4 py-10 sm:px-6 sm:py-16 lg:px-8">
        <div className="mb-8 flex items-start gap-4">
          <span className="grid size-11 shrink-0 place-items-center rounded-lg bg-primary text-primary-foreground">
            <HeartPulseIcon className="size-5" aria-hidden="true" />
          </span>
          <div>
            <p className="text-sm font-medium text-muted-foreground">
              Foundation state
            </p>
            <h1 className="mt-1 text-3xl font-semibold tracking-tight">
              Application health
            </h1>
          </div>
        </div>

        <Alert variant={healthy ? "default" : "destructive"} className="mb-6">
          {healthy ? <CheckCircle2Icon /> : <CircleAlertIcon />}
          <AlertTitle>
            {healthy
              ? "All foundation checks are healthy"
              : "The foundation is degraded"}
          </AlertTitle>
          <AlertDescription>
            {healthy
              ? "Rails is serving requests and PostgreSQL accepted a live query."
              : "Rails is responding, but at least one required foundation check is unavailable."}
          </AlertDescription>
        </Alert>

        <Card>
          <CardHeader className="sm:grid-cols-[1fr_auto]">
            <div>
              <CardTitle>Required checks</CardTitle>
              <CardDescription>
                Small, direct signals for the application foundation.
              </CardDescription>
            </div>
            <Badge
              variant={healthy ? "secondary" : "destructive"}
              className="mt-2 w-fit uppercase sm:mt-0"
            >
              {status}
            </Badge>
          </CardHeader>
          <CardContent className="space-y-0">
            <HealthCheck label="Rails application" value={checks.application} />
            <Separator />
            <HealthCheck label="PostgreSQL database" value={checks.database} />
          </CardContent>
        </Card>

        <p className="mt-6 text-sm leading-6 text-muted-foreground">
          Machines can use the framework liveness endpoint at{" "}
          <a
            className="inline-flex items-center gap-1 font-medium text-foreground underline underline-offset-4"
            href="/up"
          >
            /up
            <ExternalLinkIcon className="size-3" />
          </a>
          . This page is the human-readable foundation view.
        </p>
      </div>
    </>
  )
}

function HealthCheck({
  label,
  value,
}: {
  label: string
  value: "ok" | "unavailable"
}) {
  const available = value === "ok"

  return (
    <div className="flex items-center justify-between gap-4 py-4 first:pt-0 last:pb-0">
      <span className="font-medium">{label}</span>
      <span
        className={
          available
            ? "text-sm text-emerald-700 dark:text-emerald-400"
            : "text-sm text-destructive"
        }
      >
        {available ? "Operational" : "Unavailable"}
      </span>
    </div>
  )
}
