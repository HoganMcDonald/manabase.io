import { useCallback, useEffect, useRef, useState } from "react"

import type {
  AutocompleteCard,
  SearchCard,
  SearchResponse,
} from "@/lib/types/card"

type SearchMode = "auto" | "keyword" | "semantic" | "hybrid"
type ColorMatchMode = "exact" | "includes"

export interface SearchFilters {
  colors?: string[]
  colorMatch?: ColorMatchMode
  cmcMin?: number
  cmcMax?: number
  keywords?: string[]
  types?: string[]
  formats?: string[]
  rarities?: string[]
  powerMin?: number
  powerMax?: number
  toughnessMin?: number
  toughnessMax?: number
}

interface UseSearchOptions {
  debounceMs?: number
  autocompleteEnabled?: boolean
  autocompleteTriggerLength?: number
  autocompleteLimit?: number
  searchMode?: SearchMode
}

interface UseSearchReturn {
  // State
  query: string
  searchResults: SearchCard[]
  suggestions: AutocompleteCard[]
  isLoading: boolean
  showSuggestions: boolean
  totalResults: number
  searchMode: SearchMode
  filters: SearchFilters

  // Actions
  setQuery: (query: string) => void
  handleSearch: (searchQuery?: string) => Promise<void>
  handleSuggestionClick: (cardName: string) => void
  setShowSuggestions: (show: boolean) => void
  clearSearch: () => void
  updateFilters: (newFilters: Partial<SearchFilters>) => void
  removeFilter: (filterKey: keyof SearchFilters) => void
  clearFilters: () => void
}

export function useSearch(options: UseSearchOptions = {}): UseSearchReturn {
  const {
    debounceMs = 300,
    autocompleteEnabled = false,
    autocompleteTriggerLength = 2,
    autocompleteLimit = 10,
    searchMode = "auto",
  } = options

  const [query, setQuery] = useState("")
  const [suggestions, setSuggestions] = useState<AutocompleteCard[]>([])
  const [searchResults, setSearchResults] = useState<SearchCard[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [showSuggestions, setShowSuggestions] = useState(false)
  const [totalResults, setTotalResults] = useState(0)
  const [filters, setFilters] = useState<SearchFilters>({})

  const debounceTimeout = useRef<ReturnType<typeof setTimeout> | undefined>(
    undefined
  )

  // Autocomplete effect
  useEffect(() => {
    if (debounceTimeout.current !== undefined) {
      clearTimeout(debounceTimeout.current)
    }

    if (query.length < autocompleteTriggerLength || !autocompleteEnabled) {
      setSuggestions([])
      setShowSuggestions(false)
      return
    }

    debounceTimeout.current = setTimeout(() => {
      fetch(
        `/api/cards/autocomplete?q=${encodeURIComponent(query)}&limit=${autocompleteLimit}`
      )
        .then((res) => res.json())
        .then((data: AutocompleteCard[]) => {
          setSuggestions(data)
          setShowSuggestions(true)
        })
        .catch((error: unknown) => {
          console.error("Autocomplete error:", error)
          setSuggestions([])
        })
    }, debounceMs)

    return () => {
      if (debounceTimeout.current) {
        clearTimeout(debounceTimeout.current)
      }
    }
  }, [query, autocompleteTriggerLength, autocompleteLimit, debounceMs])

  // Build query params from filters
  const buildFilterParams = useCallback((activeFilters: SearchFilters) => {
    const params = new URLSearchParams()

    if (activeFilters.colors && activeFilters.colors.length > 0) {
      activeFilters.colors.forEach((color) => params.append("colors[]", color))
      if (activeFilters.colorMatch) {
        params.append("color_match", activeFilters.colorMatch)
      }
    }

    if (activeFilters.cmcMin !== undefined) {
      params.append("cmc_min", activeFilters.cmcMin.toString())
    }

    if (activeFilters.cmcMax !== undefined) {
      params.append("cmc_max", activeFilters.cmcMax.toString())
    }

    if (activeFilters.keywords && activeFilters.keywords.length > 0) {
      activeFilters.keywords.forEach((keyword) =>
        params.append("keywords[]", keyword)
      )
    }

    if (activeFilters.types && activeFilters.types.length > 0) {
      activeFilters.types.forEach((type) => params.append("types[]", type))
    }

    if (activeFilters.formats && activeFilters.formats.length > 0) {
      activeFilters.formats.forEach((format) =>
        params.append("formats[]", format)
      )
    }

    if (activeFilters.rarities && activeFilters.rarities.length > 0) {
      activeFilters.rarities.forEach((rarity) =>
        params.append("rarities[]", rarity)
      )
    }

    if (activeFilters.powerMin !== undefined) {
      params.append("power_min", activeFilters.powerMin.toString())
    }

    if (activeFilters.powerMax !== undefined) {
      params.append("power_max", activeFilters.powerMax.toString())
    }

    if (activeFilters.toughnessMin !== undefined) {
      params.append("toughness_min", activeFilters.toughnessMin.toString())
    }

    if (activeFilters.toughnessMax !== undefined) {
      params.append("toughness_max", activeFilters.toughnessMax.toString())
    }

    return params
  }, [])

  // Search function
  const handleSearch = useCallback(
    async (searchQuery?: string) => {
      const finalQuery = searchQuery ?? query

      // Check if we have either a query or active filters
      const hasFilters = Object.keys(filters).some((key) => {
        const value = filters[key as keyof SearchFilters]
        if (Array.isArray(value)) {
          return value.length > 0
        }
        return value !== undefined && value !== null
      })

      if (!finalQuery.trim() && !hasFilters) {
        setSearchResults([])
        setTotalResults(0)
        return
      }

      setIsLoading(true)
      setShowSuggestions(false)

      try {
        const params = buildFilterParams(filters)
        if (finalQuery.trim()) {
          params.append("q", finalQuery)
        }
        params.append("search_mode", searchMode)

        const response = await fetch(`/api/cards/search?${params.toString()}`)
        const data = (await response.json()) as SearchResponse
        setSearchResults(data.results)
        setTotalResults(data.total)
      } catch (error: unknown) {
        console.error("Search error:", error)
        setSearchResults([])
        setTotalResults(0)
      } finally {
        setIsLoading(false)
      }
    },
    [query, searchMode, filters, buildFilterParams]
  )

  // Handle suggestion click
  const handleSuggestionClick = useCallback(
    (cardName: string) => {
      setQuery(cardName)
      setShowSuggestions(false)
      void handleSearch(cardName)
    },
    [handleSearch]
  )

  // Clear search
  const clearSearch = useCallback(() => {
    setQuery("")
    setSearchResults([])
    setSuggestions([])
    setTotalResults(0)
    setShowSuggestions(false)
  }, [])

  // Update filters
  const updateFilters = useCallback((newFilters: Partial<SearchFilters>) => {
    setFilters((prev) => ({ ...prev, ...newFilters }))
  }, [])

  // Remove a specific filter
  const removeFilter = useCallback((filterKey: keyof SearchFilters) => {
    setFilters((prev) => {
      const updated = { ...prev }
      delete updated[filterKey]
      return updated
    })
  }, [])

  // Clear all filters
  const clearFilters = useCallback(() => {
    setFilters({})
  }, [])

  return {
    // State
    query,
    searchResults,
    suggestions,
    isLoading,
    showSuggestions,
    totalResults,
    searchMode,
    filters,

    // Actions
    setQuery,
    handleSearch,
    handleSuggestionClick,
    setShowSuggestions,
    clearSearch,
    updateFilters,
    removeFilter,
    clearFilters,
  }
}
