import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { EmptyState } from "@/components/states/empty-state"
import { LoadingState } from "@/components/states/loading-state"

describe("foundation UI states", () => {
  it("renders an explicit empty state", () => {
    render(<EmptyState title="Nothing here yet" description="Add the first real workflow when it is needed." />)

    expect(screen.getByRole("heading", { name: "Nothing here yet" })).toBeInTheDocument()
    expect(screen.getByText("Add the first real workflow when it is needed.")).toBeInTheDocument()
  })

  it("announces loading without changing the page structure", () => {
    render(<LoadingState />)

    expect(screen.getByLabelText("Loading content")).toHaveAttribute("aria-busy", "true")
    expect(screen.getByText("Loading…")).toBeInTheDocument()
  })
})
