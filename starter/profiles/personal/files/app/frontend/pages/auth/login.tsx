import { Head, Link, useForm } from "@inertiajs/react"
import type { FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface Props {
  return_to: string
}
export default function Login({ return_to }: Props) {
  const form = useForm({ email_address: "", password: "", return_to })
  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.post("/login")
  }
  return (
    <>
      <Head title="Sign in" />
      <Card className="mx-auto my-12 max-w-md">
        <CardHeader>
          <CardTitle>
            <h1>Sign in</h1>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <form onSubmit={submit} className="space-y-4">
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                autoComplete="email"
                required
                value={form.data.email_address}
                onChange={(event) =>
                  form.setData("email_address", event.target.value)
                }
              />
            </div>
            <div>
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                autoComplete="current-password"
                required
                value={form.data.password}
                onChange={(event) =>
                  form.setData("password", event.target.value)
                }
              />
            </div>
            <Button className="w-full" disabled={form.processing}>
              Sign in
            </Button>
          </form>
          <Link className="text-sm underline" href="/password_recovery/new">
            Forgot password?
          </Link>
        </CardContent>
      </Card>
    </>
  )
}
