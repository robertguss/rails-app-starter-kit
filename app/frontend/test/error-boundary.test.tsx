import { render, screen } from "@testing-library/react"
import { expect, test } from "vitest"

import { ErrorBoundary } from "@/components/error-boundary"

function BrokenComponent(): never {
  throw new Error("render failed")
}

test("renders a safe fallback after a React rendering failure", () => {
  const originalError = console.error
  console.error = () => undefined

  try {
    render(
      <ErrorBoundary>
        <BrokenComponent />
      </ErrorBoundary>,
    )

    expect(
      screen.getByText("This page could not be displayed"),
    ).toBeInTheDocument()
  } finally {
    console.error = originalError
  }
})
