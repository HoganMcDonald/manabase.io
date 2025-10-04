import { X } from "lucide-react"
import { type FC, useEffect, useMemo, useState } from "react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface TypesFilterProps {
  selectedTypes: string[]
  onTypesChange: (types: string[]) => void
}

export const TypesFilter: FC<TypesFilterProps> = ({
  selectedTypes,
  onTypesChange,
}) => {
  const [searchQuery, setSearchQuery] = useState("")
  const [allTypes, setAllTypes] = useState<string[]>([])
  const [isLoadingTypes, setIsLoadingTypes] = useState(true)

  // Fetch types from API on mount
  useEffect(() => {
    const fetchTypes = async () => {
      try {
        const response = await fetch("/api/cards/types")
        const data = (await response.json()) as string[]
        setAllTypes(data)
      } catch (error: unknown) {
        console.error("Failed to fetch types:", error)
        // Fallback to empty array
        setAllTypes([])
      } finally {
        setIsLoadingTypes(false)
      }
    }

    void fetchTypes()
  }, [])

  const filteredTypes = useMemo(() => {
    if (!searchQuery) return allTypes.slice(0, 20) // Show first 20 by default
    return allTypes.filter((type) =>
      type.toLowerCase().includes(searchQuery.toLowerCase())
    )
  }, [searchQuery, allTypes])

  const handleToggleType = (type: string) => {
    if (selectedTypes.includes(type)) {
      onTypesChange(selectedTypes.filter((t) => t !== type))
    } else {
      onTypesChange([...selectedTypes, type])
    }
  }

  const handleRemoveType = (type: string) => {
    onTypesChange(selectedTypes.filter((t) => t !== type))
  }

  return (
    <div className="space-y-3">
      <div>
        <Label htmlFor="type-search" className="text-sm font-medium">
          Card Types
        </Label>
      </div>

      {/* Selected types */}
      {selectedTypes.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {selectedTypes.map((type) => (
            <Badge key={type} variant="secondary" className="gap-1 pr-1">
              {type}
              <Button
                type="button"
                variant="ghost"
                size="sm"
                className="size-3.5 rounded-full p-0 hover:bg-destructive/10"
                onClick={() => handleRemoveType(type)}
              >
                <X className="size-2.5" />
              </Button>
            </Badge>
          ))}
        </div>
      )}

      {/* Search input */}
      <Input
        id="type-search"
        type="text"
        placeholder="Search card types..."
        value={searchQuery}
        onChange={(e) => setSearchQuery(e.target.value)}
        className="h-8"
      />

      {/* Available types */}
      <div className="bg-muted/50 max-h-48 overflow-y-auto rounded-md border p-2">
        <div className="flex flex-wrap gap-1.5">
          {isLoadingTypes ? (
            <p className="text-muted-foreground w-full py-4 text-center text-xs">
              Loading types...
            </p>
          ) : filteredTypes.length > 0 ? (
            filteredTypes.map((type) => {
              const isSelected = selectedTypes.includes(type)
              return (
                <button
                  key={type}
                  type="button"
                  onClick={() => handleToggleType(type)}
                  className={`text-xs px-2 py-1 rounded transition-colors ${
                    isSelected
                      ? "bg-primary text-primary-foreground"
                      : "bg-background hover:bg-accent hover:text-accent-foreground"
                  }`}
                >
                  {type}
                </button>
              )
            })
          ) : (
            <p className="text-muted-foreground w-full py-4 text-center text-xs">
              No types found
            </p>
          )}
        </div>
      </div>
    </div>
  )
}
