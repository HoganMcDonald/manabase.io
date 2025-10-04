import { X } from "lucide-react"
import type { FC } from "react"

import { Pips } from "@/components/card/pips"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import type { SearchFilters } from "@/hooks/use-search"

interface FilterPillsProps {
  filters: SearchFilters
  onRemoveFilter: (filterKey: keyof SearchFilters) => void
  onClearAll?: () => void
}

export const FilterPills: FC<FilterPillsProps> = ({
  filters,
  onRemoveFilter,
  onClearAll,
}) => {
  const hasActiveFilters = Object.keys(filters).some((key) => {
    const value = filters[key as keyof SearchFilters]
    if (Array.isArray(value)) {
      return value.length > 0
    }
    return value !== undefined && value !== null
  })

  if (!hasActiveFilters) return null

  return (
    <div className="flex flex-wrap items-center gap-2">
      {/* Color filters */}
      {filters.colors && filters.colors.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="flex items-center gap-1">
            <span className="text-xs">Colors:</span>
            <Pips
              pips={filters.colors.map((c) => `{${c}}`).join("")}
              className="gap-0.5"
            />
            {filters.colorMatch === "exact" && (
              <span className="text-muted-foreground text-xs">(exact)</span>
            )}
          </span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => {
              onRemoveFilter("colors")
              onRemoveFilter("colorMatch")
            }}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* CMC Min filter */}
      {filters.cmcMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">CMC ≥ {filters.cmcMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("cmcMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* CMC Max filter */}
      {filters.cmcMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">CMC ≤ {filters.cmcMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("cmcMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Keywords filter */}
      {filters.keywords && filters.keywords.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">
            Keywords: {filters.keywords.join(", ")}
          </span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("keywords")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Types filter */}
      {filters.types && filters.types.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Types: {filters.types.join(", ")}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("types")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Formats filter */}
      {filters.formats && filters.formats.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Formats: {filters.formats.join(", ")}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("formats")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Rarities filter */}
      {filters.rarities && filters.rarities.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">
            Rarities: {filters.rarities.join(", ")}
          </span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("rarities")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Power Min filter */}
      {filters.powerMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Power ≥ {filters.powerMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("powerMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Power Max filter */}
      {filters.powerMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Power ≤ {filters.powerMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("powerMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Toughness Min filter */}
      {filters.toughnessMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Toughness ≥ {filters.toughnessMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("toughnessMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Toughness Max filter */}
      {filters.toughnessMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Toughness ≤ {filters.toughnessMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("toughnessMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Clear all button */}
      {onClearAll && hasActiveFilters && (
        <Button
          variant="ghost"
          size="sm"
          className="text-muted-foreground h-6 text-xs"
          onClick={onClearAll}
        >
          Clear all
        </Button>
      )}
    </div>
  )
}
