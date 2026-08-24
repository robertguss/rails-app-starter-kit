// Password enrollment interface.
import { Head, useForm } from "@inertiajs/react"
import type { FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
export default function Invitation({ token }: { token: string }) {
  const form = useForm({ name: "", password: "", password_confirmation: "" })
  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.patch(`/invitations/${token}`)
  }
  return (
    <>
      <Head title="Accept invitation" />
      <Card className="mx-auto my-12 max-w-md">
        <CardHeader>
          <CardTitle>Accept invitation</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={submit} className="space-y-4">
            <Label htmlFor="name">Name</Label>
            <Input
              id="name"
              required
              value={form.data.name}
              onChange={(e) => form.setData("name", e.target.value)}
            />
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              minLength={12}
              required
              value={form.data.password}
              onChange={(e) => form.setData("password", e.target.value)}
            />
            {form.errors.password && (
              <p className="text-sm text-destructive">{form.errors.password}</p>
            )}
            <Label htmlFor="password-confirmation">Confirm password</Label>
            <Input
              id="password-confirmation"
              type="password"
              minLength={12}
              required
              value={form.data.password_confirmation}
              onChange={(e) =>
                form.setData("password_confirmation", e.target.value)
              }
            />
            <Button className="w-full" disabled={form.processing}>
              Create account
            </Button>
          </form>
        </CardContent>
      </Card>
    </>
  )
}
