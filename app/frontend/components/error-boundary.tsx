import { Component, type ErrorInfo, type ReactNode } from "react"

import { ErrorState } from "@/components/states/error-state"

interface ErrorBoundaryProps {
  children: ReactNode
}

interface ErrorBoundaryState {
  failed: boolean
}

export class ErrorBoundary extends Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  state: ErrorBoundaryState = { failed: false }

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { failed: true }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error("React render failure", {
      error,
      componentStack: info.componentStack,
    })
  }

  render() {
    if (this.state.failed) {
      return (
        <ErrorState
          code="client"
          title="This page could not be displayed"
          description="Reload the page. If the problem continues, share the request ID from the response headers with the application owner."
        />
      )
    }

    return this.props.children
  }
}
