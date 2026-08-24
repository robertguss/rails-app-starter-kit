import { Head, useForm } from "@inertiajs/react"
import type { FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
export default function RecoveryRequest() {
  const form = useForm({ email_address: "" })
  return (
    <>
      <Head title="Recover password" />
      <Card className="mx-auto my-12 max-w-md">
        <CardHeader>
          <CardTitle>Recover password</CardTitle>
        </CardHeader>
        <CardContent>
          <form
            className="space-y-4"
            onSubmit={(e: FormEvent) => {
              e.preventDefault()
              form.post("/password_recovery")
            }}
          >
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              required
              value={form.data.email_address}
              onChange={(e) => form.setData("email_address", e.target.value)}
            />
            <Button className="w-full">Send recovery instructions</Button>
          </form>
        </CardContent>
      </Card>
    </>
  )
}
