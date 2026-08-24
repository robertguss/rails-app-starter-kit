import { Head } from "@inertiajs/react"
import { useEffect, useState } from "react"

import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import type { Operation } from "@/pages/operations/index"

interface Item {
  id: number
  external_key: string
  status: string
  input_summary: { name?: string; state?: string }
  result_summary: Record<string, string>
  error_category: string | null
  error_message: string | null
}

interface Props {
  operation: Operation
  items: Item[]
}

const terminalStatuses = ["succeeded", "partially_succeeded", "failed"]

export default function OperationShow(props: Props) {
  const [operation, setOperation] = useState(props.operation)
  const [items, setItems] = useState(props.items)

  useEffect(() => {
    if (terminalStatuses.includes(operation.status)) return

    let cancelled = false
    let delay = 2000
    let timer: number

    function schedule() {
      timer = window.setTimeout(poll, delay)
    }

    async function poll() {
      if (cancelled || document.hidden) return

      try {
        const response = await fetch(`/operations/${operation.id}/status`, {
          headers: { Accept: "application/json" },
        })
        if (!response.ok) throw new Error("status polling failed")

        const payload = (await response.json()) as Props
        delay = 2000
        setOperation(payload.operation)
        setItems(payload.items)
        if (!terminalStatuses.includes(payload.operation.status)) schedule()
      } catch {
        delay = Math.min(delay * 2, 10000)
        schedule()
      }
    }

    function visibilityChanged() {
      window.clearTimeout(timer)
      if (!document.hidden) {
        delay = 2000
        void poll()
      }
    }

    document.addEventListener("visibilitychange", visibilityChanged)
    schedule()
    return () => {
      cancelled = true
      window.clearTimeout(timer)
      document.removeEventListener("visibilitychange", visibilityChanged)
    }
  }, [operation.id, operation.status])

  const percent =
    operation.progress_total > 0
      ? (operation.progress_current / operation.progress_total) * 100
      : 0

  return (
    <>
      <Head title={`Operation ${operation.id}`} />
      <div className="mx-auto w-full max-w-5xl space-y-8 px-4 py-10 sm:px-6 lg:px-8">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <p className="text-sm text-muted-foreground">
              Fake-provider fixture import
            </p>
            <h1 className="text-3xl font-semibold tracking-tight">
              Operation #{operation.id}
            </h1>
          </div>
          <Badge
            variant={
              operation.status === "failed" ? "destructive" : "secondary"
            }
          >
            {operation.status.replaceAll("_", " ")}
          </Badge>
        </div>

        <section className="space-y-3" aria-live="polite" aria-atomic="true">
          <div className="flex justify-between text-sm">
            <span>{operation.current_step || "Waiting for a worker"}</span>
            <span>
              {operation.progress_current} / {operation.progress_total || "?"}
            </span>
          </div>
          <Progress value={percent} />
          {!terminalStatuses.includes(operation.status) ? (
            <p className="text-sm text-muted-foreground">
              Progress refreshes automatically.
            </p>
          ) : null}
          {operation.error_message ? (
            <p
              role="alert"
              className="rounded-md bg-destructive/10 p-3 text-sm text-destructive"
            >
              {operation.error_message}
            </p>
          ) : null}
        </section>

        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Record</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Result</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {items.map((item) => (
              <TableRow key={item.id}>
                <TableCell>
                  <span className="font-medium">
                    {item.input_summary.name || item.external_key}
                  </span>
                  <div className="text-xs text-muted-foreground">
                    {item.external_key}
                  </div>
                </TableCell>
                <TableCell>{item.status}</TableCell>
                <TableCell className="max-w-md text-sm">
                  {item.error_message || item.result_summary.outcome || "—"}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </>
  )
}
