import { useCallback, useEffect, useRef, useState } from "react"

import type {
  AutocompleteCard,
  SearchCard,
  SearchResponse,
} from "@/lib/types/card"

interface UseSearchOptions {
  debounceMs?: number
  autocompleteTriggerLength?: number
  autocompleteLimit?: number
}

interface UseSearchReturn {
  // State
  query: string
  searchResults: SearchCard[]
  suggestions: AutocompleteCard[]
  isLoading: boolean
  showSuggestions: boolean
  totalResults: number

  // Actions
  setQuery: (query: string) => void
  handleSearch: (searchQuery?: string) => Promise<void>
  handleSuggestionClick: (cardName: string) => void
  setShowSuggestions: (show: boolean) => void
  clearSearch: () => void
}

export function useSearch(options: UseSearchOptions = {}): UseSearchReturn {
  const {
    debounceMs = 300,
    autocompleteTriggerLength = 2,
    autocompleteLimit = 10,
  } = options

  const [query, setQuery] = useState("")
  const [suggestions, setSuggestions] = useState<AutocompleteCard[]>([])
  const [searchResults, setSearchResults] = useState<SearchCard[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [showSuggestions, setShowSuggestions] = useState(false)
  const [totalResults, setTotalResults] = useState(0)

  const debounceTimeout = useRef<ReturnType<typeof setTimeout> | undefined>(
    undefined
  )

  // Autocomplete effect
  useEffect(() => {
    if (debounceTimeout.current !== undefined) {
      clearTimeout(debounceTimeout.current)
    }

    if (query.length < autocompleteTriggerLength) {
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

  // Search function
  const handleSearch = useCallback(
    async (searchQuery?: string) => {
      const finalQuery = searchQuery ?? query

      if (!finalQuery.trim()) {
        setSearchResults([])
        setTotalResults(0)
        return
      }

      setIsLoading(true)
      setShowSuggestions(false)

      try {
        const response = await fetch(
          `/api/cards/search?q=${encodeURIComponent(finalQuery)}`
        )
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
    [query]
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

  return {
    // State
    query,
    searchResults,
    suggestions,
    isLoading,
    showSuggestions,
    totalResults,

    // Actions
    setQuery,
    handleSearch,
    handleSuggestionClick,
    setShowSuggestions,
    clearSearch,
  }
}
