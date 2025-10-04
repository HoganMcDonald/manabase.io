import { X } from "lucide-react"
import { type FC, useEffect, useMemo, useState } from "react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface KeywordsFilterProps {
  selectedKeywords: string[]
  onKeywordsChange: (keywords: string[]) => void
}

export const KeywordsFilter: FC<KeywordsFilterProps> = ({
  selectedKeywords,
  onKeywordsChange,
}) => {
  const [searchQuery, setSearchQuery] = useState("")
  const [allKeywords, setAllKeywords] = useState<string[]>([])
  const [isLoadingKeywords, setIsLoadingKeywords] = useState(true)

  // Fetch keywords from API on mount
  useEffect(() => {
    const fetchKeywords = async () => {
      try {
        const response = await fetch("/api/cards/keywords")
        const data = (await response.json()) as string[]
        setAllKeywords(data)
      } catch (error: unknown) {
        console.error("Failed to fetch keywords:", error)
        // Fallback to empty array
        setAllKeywords([])
      } finally {
        setIsLoadingKeywords(false)
      }
    }

    void fetchKeywords()
  }, [])

  const filteredKeywords = useMemo(() => {
    if (!searchQuery) return allKeywords.slice(0, 20) // Show first 20 by default
    return allKeywords.filter((keyword) =>
      keyword.toLowerCase().includes(searchQuery.toLowerCase())
    )
  }, [searchQuery, allKeywords])

  const handleToggleKeyword = (keyword: string) => {
    if (selectedKeywords.includes(keyword)) {
      onKeywordsChange(selectedKeywords.filter((k) => k !== keyword))
    } else {
      onKeywordsChange([...selectedKeywords, keyword])
    }
  }

  const handleRemoveKeyword = (keyword: string) => {
    onKeywordsChange(selectedKeywords.filter((k) => k !== keyword))
  }

  return (
    <div className="space-y-3">
      <div>
        <Label htmlFor="keyword-search" className="text-sm font-medium">
          Keywords
        </Label>
      </div>

      {/* Selected keywords */}
      {selectedKeywords.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {selectedKeywords.map((keyword) => (
            <Badge key={keyword} variant="secondary" className="gap-1 pr-1">
              {keyword}
              <Button
                type="button"
                variant="ghost"
                size="sm"
                className="size-3.5 rounded-full p-0 hover:bg-destructive/10"
                onClick={() => handleRemoveKeyword(keyword)}
              >
                <X className="size-2.5" />
              </Button>
            </Badge>
          ))}
        </div>
      )}

      {/* Search input */}
      <Input
        id="keyword-search"
        type="text"
        placeholder="Search keywords..."
        value={searchQuery}
        onChange={(e) => setSearchQuery(e.target.value)}
        className="h-8"
      />

      {/* Available keywords */}
      <div className="bg-muted/50 max-h-48 overflow-y-auto rounded-md border p-2">
        <div className="flex flex-wrap gap-1.5">
          {isLoadingKeywords ? (
            <p className="text-muted-foreground w-full py-4 text-center text-xs">
              Loading keywords...
            </p>
          ) : filteredKeywords.length > 0 ? (
            filteredKeywords.map((keyword) => {
              const isSelected = selectedKeywords.includes(keyword)
              return (
                <button
                  key={keyword}
                  type="button"
                  onClick={() => handleToggleKeyword(keyword)}
                  className={`text-xs px-2 py-1 rounded transition-colors ${
                    isSelected
                      ? "bg-primary text-primary-foreground"
                      : "bg-background hover:bg-accent hover:text-accent-foreground"
                  }`}
                >
                  {keyword}
                </button>
              )
            })
          ) : (
            <p className="text-muted-foreground w-full py-4 text-center text-xs">
              No keywords found
            </p>
          )}
        </div>
      </div>
    </div>
  )
}
