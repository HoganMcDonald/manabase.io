import type { FC } from "react"

import { Label } from "@/components/ui/label"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"

interface BorderColorsFilterProps {
  selectedBorderColors: string[]
  onBorderColorsChange: (borderColors: string[]) => void
}

const BORDER_COLORS = [
  { value: "black", label: "Black" },
  { value: "white", label: "White" },
  { value: "borderless", label: "Borderless" },
  { value: "silver", label: "Silver" },
  { value: "gold", label: "Gold" },
] as const

export const BorderColorsFilter: FC<BorderColorsFilterProps> = ({
  selectedBorderColors,
  onBorderColorsChange,
}) => {
  const handleValueChange = (values: string[]) => {
    onBorderColorsChange(values)
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Border Color</Label>
      </div>

      <ToggleGroup
        type="multiple"
        value={selectedBorderColors}
        onValueChange={handleValueChange}
        className="flex-wrap justify-start gap-2"
      >
        {BORDER_COLORS.map((border) => (
          <ToggleGroupItem
            key={border.value}
            value={border.value}
            className="text-xs"
          >
            {border.label}
          </ToggleGroupItem>
        ))}
      </ToggleGroup>
    </div>
  )
}
