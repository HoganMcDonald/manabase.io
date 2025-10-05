import type { FC } from "react"

import { Label } from "@/components/ui/label"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"

interface FinishesFilterProps {
  selectedFinishes: string[]
  onFinishesChange: (finishes: string[]) => void
}

const FINISHES = [
  { value: "nonfoil", label: "Nonfoil" },
  { value: "foil", label: "Foil" },
  { value: "etched", label: "Etched" },
  { value: "glossy", label: "Glossy" },
] as const

export const FinishesFilter: FC<FinishesFilterProps> = ({
  selectedFinishes,
  onFinishesChange,
}) => {
  const handleValueChange = (values: string[]) => {
    onFinishesChange(values)
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Finishes</Label>
      </div>

      <ToggleGroup
        type="multiple"
        value={selectedFinishes}
        onValueChange={handleValueChange}
        className="flex-wrap justify-start gap-2"
      >
        {FINISHES.map((finish) => (
          <ToggleGroupItem
            key={finish.value}
            value={finish.value}
            className="text-xs"
          >
            {finish.label}
          </ToggleGroupItem>
        ))}
      </ToggleGroup>
    </div>
  )
}
