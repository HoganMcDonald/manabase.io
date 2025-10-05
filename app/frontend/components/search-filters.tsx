import { ChevronDown, Filter } from "lucide-react"
import { type FC, useState } from "react"

import { ArtistsFilter } from "@/components/artists-filter"
import { BorderColorsFilter } from "@/components/border-colors-filter"
import { CardCharacteristicsFilter } from "@/components/card-characteristics-filter"
import { CmcFilter } from "@/components/cmc-filter"
import { ColorIdentityFilter } from "@/components/color-identity-filter"
import { ColorTypeFilter } from "@/components/color-type-filter"
import { EdhrecRankFilter } from "@/components/edhrec-rank-filter"
import { FinishesFilter } from "@/components/finishes-filter"
import { FormatFilter } from "@/components/format-filter"
import { KeywordsFilter } from "@/components/keywords-filter"
import { LoyaltyFilter } from "@/components/loyalty-filter"
import { PlatformFilter } from "@/components/platform-filter"
import { PowerToughnessFilter } from "@/components/power-toughness-filter"
import { PriceFilter } from "@/components/price-filter"
import { ProducedManaFilter } from "@/components/produced-mana-filter"
import { RarityFilter } from "@/components/rarity-filter"
import { ReleaseDateFilter } from "@/components/release-date-filter"
import { SetsFilter } from "@/components/sets-filter"
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

  const handleLoyaltyMinChange = (loyaltyMin?: number) => {
    onFiltersChange({ loyaltyMin })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleLoyaltyMaxChange = (loyaltyMax?: number) => {
    onFiltersChange({ loyaltyMax })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleOnArenaChange = (onArena: boolean) => {
    onFiltersChange({ onArena })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleOnMtgoChange = (onMtgo: boolean) => {
    onFiltersChange({ onMtgo })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleColorlessChange = (colorless: boolean) => {
    onFiltersChange({ colorless })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleMonoColorChange = (monoColor: boolean) => {
    onFiltersChange({ monoColor })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleMulticolorChange = (multicolor: boolean) => {
    onFiltersChange({ multicolor })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePromoChange = (promo: boolean) => {
    onFiltersChange({ promo })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleReprintChange = (reprint: boolean) => {
    onFiltersChange({ reprint })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleDigitalChange = (digital: boolean) => {
    onFiltersChange({ digital })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleOversizedChange = (oversized: boolean) => {
    onFiltersChange({ oversized })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleStorySpotlightChange = (storySpotlight: boolean) => {
    onFiltersChange({ storySpotlight })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleGameChangerChange = (gameChanger: boolean) => {
    onFiltersChange({ gameChanger })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleFinishesChange = (finishes: string[]) => {
    if (finishes.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.finishes
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ finishes })
    }
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleProducedManaChange = (producedMana: string[]) => {
    if (producedMana.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.producedMana
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ producedMana })
    }
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleBorderColorsChange = (borderColors: string[]) => {
    if (borderColors.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.borderColors
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ borderColors })
    }
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleReleasedAfterChange = (releasedAfter?: string) => {
    onFiltersChange({ releasedAfter })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleReleasedBeforeChange = (releasedBefore?: string) => {
    onFiltersChange({ releasedBefore })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleEdhrecRankMinChange = (edhrecRankMin?: number) => {
    onFiltersChange({ edhrecRankMin })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleEdhrecRankMaxChange = (edhrecRankMax?: number) => {
    onFiltersChange({ edhrecRankMax })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleSetsChange = (sets: string[]) => {
    if (sets.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.sets
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ sets })
    }
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handleArtistsChange = (artists: string[]) => {
    if (artists.length === 0) {
      const newFilters = { ...filters }
      delete newFilters.artists
      onFiltersChange(newFilters)
    } else {
      onFiltersChange({ artists })
    }
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceUsdMinChange = (priceUsdMin?: number) => {
    onFiltersChange({ priceUsdMin })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceUsdMaxChange = (priceUsdMax?: number) => {
    onFiltersChange({ priceUsdMax })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceUsdFoilMinChange = (priceUsdFoilMin?: number) => {
    onFiltersChange({ priceUsdFoilMin })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceUsdFoilMaxChange = (priceUsdFoilMax?: number) => {
    onFiltersChange({ priceUsdFoilMax })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceEurMinChange = (priceEurMin?: number) => {
    onFiltersChange({ priceEurMin })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceEurMaxChange = (priceEurMax?: number) => {
    onFiltersChange({ priceEurMax })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceTixMinChange = (priceTixMin?: number) => {
    onFiltersChange({ priceTixMin })
    if (onSearch) {
      setTimeout(() => onSearch(), 100)
    }
  }

  const handlePriceTixMaxChange = (priceTixMax?: number) => {
    onFiltersChange({ priceTixMax })
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

          <Separator />

          {/* Loyalty Filter */}
          <LoyaltyFilter
            loyaltyMin={filters.loyaltyMin}
            loyaltyMax={filters.loyaltyMax}
            onLoyaltyMinChange={handleLoyaltyMinChange}
            onLoyaltyMaxChange={handleLoyaltyMaxChange}
          />

          <Separator />

          {/* Color Type Filter */}
          <ColorTypeFilter
            colorless={filters.colorless}
            monoColor={filters.monoColor}
            multicolor={filters.multicolor}
            onColorlessChange={handleColorlessChange}
            onMonoColorChange={handleMonoColorChange}
            onMulticolorChange={handleMulticolorChange}
          />

          <Separator />

          {/* Platform Availability Filter */}
          <PlatformFilter
            onArena={filters.onArena}
            onMtgo={filters.onMtgo}
            onArenaChange={handleOnArenaChange}
            onMtgoChange={handleOnMtgoChange}
          />

          <Separator />

          {/* Card Characteristics Filter */}
          <CardCharacteristicsFilter
            promo={filters.promo}
            reprint={filters.reprint}
            digital={filters.digital}
            oversized={filters.oversized}
            storySpotlight={filters.storySpotlight}
            gameChanger={filters.gameChanger}
            onPromoChange={handlePromoChange}
            onReprintChange={handleReprintChange}
            onDigitalChange={handleDigitalChange}
            onOversizedChange={handleOversizedChange}
            onStorySpotlightChange={handleStorySpotlightChange}
            onGameChangerChange={handleGameChangerChange}
          />

          <Separator />

          {/* Finishes Filter */}
          <FinishesFilter
            selectedFinishes={filters.finishes ?? []}
            onFinishesChange={handleFinishesChange}
          />

          <Separator />

          {/* Produced Mana Filter */}
          <ProducedManaFilter
            selectedColors={filters.producedMana ?? []}
            onColorsChange={handleProducedManaChange}
          />

          <Separator />

          {/* Border Colors Filter */}
          <BorderColorsFilter
            selectedBorderColors={filters.borderColors ?? []}
            onBorderColorsChange={handleBorderColorsChange}
          />

          <Separator />

          {/* Release Date Filter */}
          <ReleaseDateFilter
            releasedAfter={filters.releasedAfter}
            releasedBefore={filters.releasedBefore}
            onReleasedAfterChange={handleReleasedAfterChange}
            onReleasedBeforeChange={handleReleasedBeforeChange}
          />

          <Separator />

          {/* EDHREC Rank Filter */}
          <EdhrecRankFilter
            edhrecRankMin={filters.edhrecRankMin}
            edhrecRankMax={filters.edhrecRankMax}
            onEdhrecRankMinChange={handleEdhrecRankMinChange}
            onEdhrecRankMaxChange={handleEdhrecRankMaxChange}
          />

          <Separator />

          {/* Sets Filter */}
          <SetsFilter
            selectedSets={filters.sets ?? []}
            onSetsChange={handleSetsChange}
          />

          <Separator />

          {/* Artists Filter */}
          <ArtistsFilter
            selectedArtists={filters.artists ?? []}
            onArtistsChange={handleArtistsChange}
          />

          <Separator />

          {/* Price Filter */}
          <PriceFilter
            priceUsdMin={filters.priceUsdMin}
            priceUsdMax={filters.priceUsdMax}
            priceUsdFoilMin={filters.priceUsdFoilMin}
            priceUsdFoilMax={filters.priceUsdFoilMax}
            priceEurMin={filters.priceEurMin}
            priceEurMax={filters.priceEurMax}
            priceTixMin={filters.priceTixMin}
            priceTixMax={filters.priceTixMax}
            onPriceUsdMinChange={handlePriceUsdMinChange}
            onPriceUsdMaxChange={handlePriceUsdMaxChange}
            onPriceUsdFoilMinChange={handlePriceUsdFoilMinChange}
            onPriceUsdFoilMaxChange={handlePriceUsdFoilMaxChange}
            onPriceEurMinChange={handlePriceEurMinChange}
            onPriceEurMaxChange={handlePriceEurMaxChange}
            onPriceTixMinChange={handlePriceTixMinChange}
            onPriceTixMaxChange={handlePriceTixMaxChange}
          />
        </div>
      </CollapsibleContent>
    </Collapsible>
  )
}
