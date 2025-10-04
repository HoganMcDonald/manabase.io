import { ChevronDown, Filter } from "lucide-react"
import { type FC, useState } from "react"

import { CmcFilter } from "@/components/cmc-filter"
import { ColorIdentityFilter } from "@/components/color-identity-filter"
import { FormatFilter } from "@/components/format-filter"
import { KeywordsFilter } from "@/components/keywords-filter"
import { PowerToughnessFilter } from "@/components/power-toughness-filter"
import { RarityFilter } from "@/components/rarity-filter"
import { TypesFilter } from "@/components/types-filter"
import { Button } from "@/components/ui/button"
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible"
import { Separator } from "@/components/ui/separator"
import type { SearchFilters } from "@/hooks/use-search"

interface SearchFiltersProps {
  filters: SearchFilters
  onFiltersChange: (filters: Partial<SearchFilters>) => void
  onSearch?: () => void
}

export const SearchFiltersComponent: FC<SearchFiltersProps> = ({
  filters,
  onFiltersChange,
  onSearch,
}) => {
  const [isOpen, setIsOpen] = useState(false)

  const handleColorsChange = (colors: string[]) => {
    if (colors.length === 0) {
      // Remove both colors and colorMatch when no colors selected
      const newFilters = { ...filters }
      delete newFilters.colors
      delete newFilters.colorMatch
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ colors })
    }
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleColorMatchChange = (colorMatch: "exact" | "includes") => {
    onFiltersChange({ colorMatch })
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleCmcMinChange = (cmcMin?: number) => {
    onFiltersChange({ cmcMin })
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleCmcMaxChange = (cmcMax?: number) => {
    onFiltersChange({ cmcMax })
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleKeywordsChange = (keywords: string[]) => {
    if (keywords.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.keywords
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ keywords })
    }
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleTypesChange = (types: string[]) => {
    if (types.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.types
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ types })
    }
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleFormatsChange = (formats: string[]) => {
    if (formats.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.formats
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ formats })
    }
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleRaritiesChange = (rarities: string[]) => {
    if (rarities.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.rarities
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ rarities })
    }
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePowerMinChange = (powerMin?: number) => {
    onFiltersChange({ powerMin })
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePowerMaxChange = (powerMax?: number) => {
    onFiltersChange({ powerMax })
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleToughnessMinChange = (toughnessMin?: number) => {
    onFiltersChange({ toughnessMin })
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleToughnessMaxChange = (toughnessMax?: number) => {
    onFiltersChange({ toughnessMax })
    // Trigger search after filter change
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <CollapsibleTrigger asChild>
        <Button
          variant="outline"
          size="sm"
          className="gap-2"
          type="button"
        >
          <Filter className="size-4" />
          Advanced Filters
          <ChevronDown
            className={`size-4 transition-transform ${isOpen ? "rotate-180" : ""}`}
          />
        </Button>
      </CollapsibleTrigger>

      <CollapsibleContent className="mt-4">
        <div className="bg-muted/30 space-y-4 rounded-lg border p-4">
          {/* Color Identity Filter */}
          <ColorIdentityFilter
            selectedColors={filters.colors ?? []}
            colorMatch={filters.colorMatch ?? "includes"}
            onColorsChange={handleColorsChange}
            onColorMatchChange={handleColorMatchChange}
          />

          <Separator />

          {/* CMC Filter */}
          <CmcFilter
            cmcMin={filters.cmcMin}
            cmcMax={filters.cmcMax}
            onCmcMinChange={handleCmcMinChange}
            onCmcMaxChange={handleCmcMaxChange}
          />

          <Separator />

          {/* Keywords Filter */}
          <KeywordsFilter
            selectedKeywords={filters.keywords ?? []}
            onKeywordsChange={handleKeywordsChange}
          />

          <Separator />

          {/* Card Types Filter */}
          <TypesFilter
            selectedTypes={filters.types ?? []}
            onTypesChange={handleTypesChange}
          />

          <Separator />

          {/* Format Legality Filter */}
          <FormatFilter
            selectedFormats={filters.formats ?? []}
            onFormatsChange={handleFormatsChange}
          />

          <Separator />

          {/* Rarity Filter */}
          <RarityFilter
            selectedRarities={filters.rarities ?? []}
            onRaritiesChange={handleRaritiesChange}
          />

          <Separator />

          {/* Power/Toughness Filter */}
          <PowerToughnessFilter
            powerMin={filters.powerMin}
            powerMax={filters.powerMax}
            toughnessMin={filters.toughnessMin}
            toughnessMax={filters.toughnessMax}
            onPowerMinChange={handlePowerMinChange}
            onPowerMaxChange={handlePowerMaxChange}
            onToughnessMinChange={handleToughnessMinChange}
            onToughnessMaxChange={handleToughnessMaxChange}
          />
        </div>
      </CollapsibleContent>
    </Collapsible>
  )
}
