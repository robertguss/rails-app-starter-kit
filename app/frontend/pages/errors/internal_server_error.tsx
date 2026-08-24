import { Head } from "@inertiajs/react"

import { ErrorState } from "@/components/states/error-state"

export default function InternalServerErrorPage() {
  return (
    <>
      <Head title="Application error" />
      <ErrorState
        code="500"
        title="The application could not complete that request"
        description="The failure has stayed inside the application boundary. Try again, or return to the foundation."
      />
    </>
  )
}
