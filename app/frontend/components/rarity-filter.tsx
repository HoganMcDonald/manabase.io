import type { FC } from "react"

import { Label } from "@/components/ui/label"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"

interface RarityFilterProps {
  selectedRarities: string[]
  onRaritiesChange: (rarities: string[]) => void
}

const RARITIES = [
  { value: "common", label: "Common", color: "text-slate-600" },
  { value: "uncommon", label: "Uncommon", color: "text-slate-400" },
  { value: "rare", label: "Rare", color: "text-yellow-600" },
  { value: "mythic", label: "Mythic", color: "text-orange-600" },
] as const

export const RarityFilter: FC<RarityFilterProps> = ({
  selectedRarities,
  onRaritiesChange,
}) => {
  const handleValueChange = (values: string[]) => {
    onRaritiesChange(values)
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Rarity</Label>
      </div>

      <ToggleGroup
        type="multiple"
        value={selectedRarities}
        onValueChange={handleValueChange}
        className="flex-wrap justify-start gap-2"
      >
        {RARITIES.map((rarity) => (
          <ToggleGroupItem
            key={rarity.value}
            value={rarity.value}
            className="text-xs"
          >
            {rarity.label}
          </ToggleGroupItem>
        ))}
      </ToggleGroup>
    </div>
  )
}
