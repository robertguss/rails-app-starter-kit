import { Head, useForm } from "@inertiajs/react"
import type { FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
export default function RecoveryReset({ token }: { token: string }) {
  const form = useForm({ token, password: "", password_confirmation: "" })
  return (
    <>
      <Head title="Reset password" />
      <Card className="mx-auto my-12 max-w-md">
        <CardHeader>
          <CardTitle>Choose a new password</CardTitle>
        </CardHeader>
        <CardContent>
          <form
            className="space-y-4"
            onSubmit={(e: FormEvent) => {
              e.preventDefault()
              form.patch("/password_recovery")
            }}
          >
            <Label htmlFor="password">New password</Label>
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
              Change password
            </Button>
          </form>
        </CardContent>
      </Card>
    </>
  )
}
