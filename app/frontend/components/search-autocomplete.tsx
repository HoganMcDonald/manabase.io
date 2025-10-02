import type { FC } from "react"

import { Pips } from "@/components/card/pips"
import type { AutocompleteCard } from "@/lib/types/card"

interface SearchAutocompleteProps {
  suggestions: AutocompleteCard[]
  show: boolean
  onSuggestionClick: (cardName: string) => void
  onClose: () => void
}

export const SearchAutocomplete: FC<SearchAutocompleteProps> = ({
  suggestions,
  show,
  onSuggestionClick,
  onClose,
}) => {
  if (!show || suggestions.length === 0) return null

  return (
    <div className="bg-background border-border absolute left-0 right-0 top-full z-10 mt-1 max-h-96 overflow-y-auto rounded-md border shadow-lg">
      {suggestions.map((card) => (
        <button
          key={card.id}
          type="button"
          className="hover:bg-accent flex w-full items-start gap-3 border-b px-4 py-3 text-left transition-colors last:border-b-0"
          onClick={() => onSuggestionClick(card.name)}
          onBlur={() => {
            // Delay to allow click to register
            setTimeout(() => onClose(), 200)
          }}
        >
          <div className="flex-1">
            <div className="font-medium">{card.name}</div>
            <div className="text-muted-foreground text-sm">{card.type_line}</div>
          </div>
          {card.mana_cost && (
            <div className="flex items-center">
              <Pips pips={card.mana_cost} />
            </div>
          )}
        </button>
      ))}
    </div>
  )
}
