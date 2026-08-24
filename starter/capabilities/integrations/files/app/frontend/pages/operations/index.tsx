import { Head, Link, useForm } from "@inertiajs/react"
import type { FormEvent } from "react"

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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

export interface Operation {
  id: number
  kind: string
  status: string
  current_step: string | null
  progress_current: number
  progress_total: number
  result_summary: Record<string, number>
  error_category: string | null
  error_message: string | null
  actor: string
  created_at: string
  started_at: string | null
  finished_at: string | null
}

interface Props {
  operations: Operation[]
  simulations: string[]
}

export default function OperationsIndex({ operations, simulations }: Props) {
  const form = useForm({ simulation: "success", idempotency_key: "" })

  function submit(event: FormEvent) {
    event.preventDefault()
    form.transform((data) => ({
      ...data,
      idempotency_key: crypto.randomUUID(),
    }))
    form.post("/operations")
  }

  return (
    <>
      <Head title="Operations" />
      <div className="mx-auto w-full max-w-5xl space-y-8 px-4 py-10 sm:px-6 lg:px-8">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight">Operations</h1>
          <p className="mt-2 text-muted-foreground">
            Durable, idempotent integration work with visible progress.
          </p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Fake-provider fixture import</CardTitle>
            <CardDescription>
              Exercises the provider-neutral integration boundary without an
              institutional provider or production credential.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form
              className="flex flex-col gap-4 sm:flex-row sm:items-end"
              onSubmit={submit}
            >
              {simulations.length > 0 ? (
                <div className="w-full space-y-2 sm:max-w-xs">
                  <Label htmlFor="simulation">Failure simulation</Label>
                  <Select
                    value={form.data.simulation}
                    onValueChange={(value) => form.setData("simulation", value)}
                  >
                    <SelectTrigger id="simulation">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {simulations.map((simulation) => (
                        <SelectItem key={simulation} value={simulation}>
                          {simulation.replaceAll("_", " ")}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              ) : null}
              <Button disabled={form.processing}>
                {form.processing ? "Starting…" : "Start fixture import"}
              </Button>
            </form>
          </CardContent>
        </Card>

        <section aria-labelledby="recent-operations">
          <h2 id="recent-operations" className="text-xl font-semibold">
            Recent operations
          </h2>
          {operations.length === 0 ? (
            <p className="mt-4 rounded-lg border border-dashed p-8 text-center text-muted-foreground">
              No operations yet.
            </p>
          ) : (
            <div className="mt-4 grid gap-3">
              {operations.map((operation) => (
                <Link
                  key={operation.id}
                  href={`/operations/${operation.id}`}
                  className="rounded-lg border p-4 transition-colors hover:bg-accent"
                >
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <span className="font-medium">
                      Fixture import #{operation.id}
                    </span>
                    <Badge
                      variant={
                        operation.status === "failed"
                          ? "destructive"
                          : "secondary"
                      }
                    >
                      {operation.status.replaceAll("_", " ")}
                    </Badge>
                  </div>
                  <p className="mt-2 text-sm text-muted-foreground">
                    {operation.progress_current} of{" "}
                    {operation.progress_total || "?"} records · requested by{" "}
                    {operation.actor}
                  </p>
                </Link>
              ))}
            </div>
          )}
        </section>
      </div>
    </>
  )
}
