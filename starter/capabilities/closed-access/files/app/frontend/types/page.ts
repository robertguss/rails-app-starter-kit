// Closed-access shared page properties.
export interface SharedPageProps {
  [key: string]: unknown
  auth: {
    user: {
      email_address: string
      id: number
      name: string
      role: "member" | "owner"
    } | null
  }
  flash: {
    alert?: string
    notice?: string
  }
}
