import { Head, router, useForm } from "@inertiajs/react"
import type { FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
interface Grant {
  id: number
  email: string
  active: boolean
  name: string | null
  role: string | null
}
interface Props {
  grants: Grant[]
}
export default function Access({ grants }: Props) {
  const form = useForm({ email: "" })
  return (
    <div className="mx-auto max-w-4xl p-6">
      <Head title="Access settings" />
      <h1 className="text-3xl font-semibold">Access</h1>
      <form
        className="my-6 flex gap-2"
        onSubmit={(e: FormEvent) => {
          e.preventDefault()
          form.post("/settings/access")
        }}
      >
        <Input
          aria-label="Email"
          type="email"
          required
          value={form.data.email}
          onChange={(e) => form.setData("email", e.target.value)}
        />
        <Button>Grant and invite</Button>
      </form>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Person</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {grants.map((g) => (
            <TableRow key={g.id}>
              <TableCell>
                {g.name || g.email}
                <div className="text-sm text-muted-foreground">{g.email}</div>
              </TableCell>
              <TableCell>
                {g.active ? g.role || "invited" : "revoked"}
              </TableCell>
              <TableCell className="space-x-2">
                {g.active && g.role !== "owner" && (
                  <Button
                    variant="outline"
                    onClick={() => router.delete(`/settings/access/${g.id}`)}
                  >
                    Revoke
                  </Button>
                )}
                {g.active && g.role === "member" && (
                  <Button
                    onClick={() =>
                      router.post(`/settings/access/${g.id}/transfer`)
                    }
                  >
                    Transfer ownership
                  </Button>
                )}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )
}
