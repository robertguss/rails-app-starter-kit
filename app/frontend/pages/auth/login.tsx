import { Head, Link, useForm } from "@inertiajs/react"
import type { FormEvent } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface Props {
  csrf_token: string
  return_to: string
  methods: string[]
}
export default function Login({ csrf_token, return_to, methods }: Props) {
  const form = useForm({ email_address: "", password: "", return_to })
  const submit = (e: FormEvent) => {
    e.preventDefault()
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
          {methods.includes("password") && (
            <form onSubmit={submit} className="space-y-4">
              <div>
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={form.data.email_address}
                  onChange={(e) =>
                    form.setData("email_address", e.target.value)
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
                  onChange={(e) => form.setData("password", e.target.value)}
                />
              </div>
              <Button className="w-full" disabled={form.processing}>
                Sign in
              </Button>
            </form>
          )}
          {methods.includes("google") && (
            <form method="post" action="/auth/google_oauth2">
              <input
                type="hidden"
                name="authenticity_token"
                value={csrf_token}
              />
              <input type="hidden" name="origin" value={return_to} />
              <Button variant="outline" className="w-full">
                Continue with Google
              </Button>
            </form>
          )}
          {methods.includes("password") && (
            <Link className="text-sm underline" href="/password_recovery/new">
              Forgot password?
            </Link>
          )}
        </CardContent>
      </Card>
    </>
  )
}
