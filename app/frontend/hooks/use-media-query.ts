import { useEffect, useState } from "react"

const BREAKPOINTS = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  "2xl": 1536,
}

export function useMediaQuery() {
  const [isSmall, setIsSmall] = useState(false)
  const [isMedium, setIsMedium] = useState(false)
  const [isLarge, setIsLarge] = useState(false)
  const [isXLarge, setIsXLarge] = useState(false)
  const [is2XLarge, setIs2XLarge] = useState(false)

  useEffect(() => {
    const updateBreakpoints = () => {
      const width = window.innerWidth
      setIsSmall(width >= BREAKPOINTS.sm)
      setIsMedium(width >= BREAKPOINTS.md)
      setIsLarge(width >= BREAKPOINTS.lg)
      setIsXLarge(width >= BREAKPOINTS.xl)
      setIs2XLarge(width >= BREAKPOINTS["2xl"])
    }

    // Set initial values
    updateBreakpoints()

    // Add event listener
    window.addEventListener("resize", updateBreakpoints)

    // Cleanup
    return () => window.removeEventListener("resize", updateBreakpoints)
  }, [])

  return {
    isSmall,
    isMedium,
    isLarge,
    isXLarge,
    is2XLarge,
  }
}
