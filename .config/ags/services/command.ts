import { execAsync } from "ags/process"

export async function output(argv: string[], fallback = "") {
  try {
    return await execAsync(argv)
  } catch {
    return fallback
  }
}

export function run(argv: string[]) {
  execAsync(argv).catch((error) => console.error(error))
}
