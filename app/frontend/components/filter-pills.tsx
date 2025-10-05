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

      {/* Loyalty Min filter */}
      {filters.loyaltyMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Loyalty ≥ {filters.loyaltyMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("loyaltyMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Loyalty Max filter */}
      {filters.loyaltyMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Loyalty ≤ {filters.loyaltyMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("loyaltyMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Colorless filter */}
      {filters.colorless && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Colorless</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("colorless")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Mono-color filter */}
      {filters.monoColor && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Mono-colored</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("monoColor")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Multicolor filter */}
      {filters.multicolor && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Multicolored</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("multicolor")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* On Arena filter */}
      {filters.onArena && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">On Arena</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("onArena")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* On MTGO filter */}
      {filters.onMtgo && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">On MTGO</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("onMtgo")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Promo filter */}
      {filters.promo && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Promo</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("promo")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Reprint filter */}
      {filters.reprint && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Reprint</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("reprint")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Digital filter */}
      {filters.digital && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Digital</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("digital")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Oversized filter */}
      {filters.oversized && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Oversized</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("oversized")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Story Spotlight filter */}
      {filters.storySpotlight && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Story Spotlight</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("storySpotlight")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Game Changer filter */}
      {filters.gameChanger && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Game Changer</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("gameChanger")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Finishes filter */}
      {filters.finishes && filters.finishes.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Finishes: {filters.finishes.join(", ")}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("finishes")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Produced Mana filter */}
      {filters.producedMana && filters.producedMana.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="flex items-center gap-1">
            <span className="text-xs">Produces:</span>
            <Pips
              pips={filters.producedMana.map((c) => `{${c}}`).join("")}
              className="gap-0.5"
            />
          </span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("producedMana")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Border Colors filter */}
      {filters.borderColors && filters.borderColors.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">
            Border: {filters.borderColors.join(", ")}
          </span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("borderColors")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Released After filter */}
      {filters.releasedAfter && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Released ≥ {filters.releasedAfter}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("releasedAfter")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Released Before filter */}
      {filters.releasedBefore && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Released ≤ {filters.releasedBefore}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("releasedBefore")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* EDHREC Rank Min filter */}
      {filters.edhrecRankMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">EDHREC ≥ {filters.edhrecRankMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("edhrecRankMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* EDHREC Rank Max filter */}
      {filters.edhrecRankMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">EDHREC ≤ {filters.edhrecRankMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("edhrecRankMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Sets filter */}
      {filters.sets && filters.sets.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Sets: {filters.sets.join(", ")}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("sets")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Artists filter */}
      {filters.artists && filters.artists.length > 0 && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">Artists: {filters.artists.join(", ")}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("artists")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price USD Min filter */}
      {filters.priceUsdMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">USD ≥ ${filters.priceUsdMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceUsdMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price USD Max filter */}
      {filters.priceUsdMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">USD ≤ ${filters.priceUsdMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceUsdMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price USD Foil Min filter */}
      {filters.priceUsdFoilMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">USD Foil ≥ ${filters.priceUsdFoilMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceUsdFoilMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price USD Foil Max filter */}
      {filters.priceUsdFoilMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">USD Foil ≤ ${filters.priceUsdFoilMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceUsdFoilMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price EUR Min filter */}
      {filters.priceEurMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">EUR ≥ €{filters.priceEurMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceEurMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price EUR Max filter */}
      {filters.priceEurMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">EUR ≤ €{filters.priceEurMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceEurMax")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price TIX Min filter */}
      {filters.priceTixMin !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">TIX ≥ {filters.priceTixMin}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceTixMin")}
          >
            <X className="size-3" />
          </Button>
        </Badge>
      )}

      {/* Price TIX Max filter */}
      {filters.priceTixMax !== undefined && (
        <Badge variant="outline" className="gap-2 pr-1">
          <span className="text-xs">TIX ≤ {filters.priceTixMax}</span>
          <Button
            variant="ghost"
            size="sm"
            className="size-4 rounded-full p-0 hover:bg-destructive/10"
            onClick={() => onRemoveFilter("priceTixMax")}
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
