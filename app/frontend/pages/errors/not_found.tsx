import { Head } from "@inertiajs/react"

import { ErrorState } from "@/components/states/error-state"

export default function NotFoundPage() {
  return (
    <>
      <Head title="Page not found" />
      <ErrorState
        code="404"
        title="That page does not exist"
        description="The address may be incorrect, or the page may have moved. Use the application navigation or return to the foundation."
      />
    </>
  )
}
