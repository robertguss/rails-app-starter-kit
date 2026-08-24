export interface SharedPageProps {
  [key: string]: unknown
  flash: {
    alert?: string
    notice?: string
  }
}
