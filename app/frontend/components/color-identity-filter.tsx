import { cx } from "class-variance-authority"
import type { FC } from "react"

import {
  ColorlessIcon,
  ForestIcon,
  IslandIcon,
  MountainIcon,
  PlainsIcon,
  SwampIcon,
} from "@/components/icon"
import { Label } from "@/components/ui/label"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"

interface ColorIdentityFilterProps {
  selectedColors: string[]
  colorMatch: "exact" | "includes"
  onColorsChange: (colors: string[]) => void
  onColorMatchChange: (match: "exact" | "includes") => void
}

const COLORS = [
  { code: "W", name: "White", icon: PlainsIcon, bg: "bg-magic-white-bg" },
  { code: "U", name: "Blue", icon: IslandIcon, bg: "bg-magic-blue-bg" },
  { code: "B", name: "Black", icon: SwampIcon, bg: "bg-magic-black-bg" },
  { code: "R", name: "Red", icon: MountainIcon, bg: "bg-magic-red-bg" },
  { code: "G", name: "Green", icon: ForestIcon, bg: "bg-magic-green-bg" },
  {
    code: "C",
    name: "Colorless",
    icon: ColorlessIcon,
    bg: "bg-magic-colorless-bg",
  },
] as const

export const ColorIdentityFilter: FC<ColorIdentityFilterProps> = ({
  selectedColors,
  colorMatch,
  onColorsChange,
  onColorMatchChange,
}) => {
  const handleColorToggle = (color: string) => {
    if (selectedColors.includes(color)) {
      onColorsChange(selectedColors.filter((c) => c !== color))
    } else {
      onColorsChange([...selectedColors, color])
    }
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Color Identity</Label>
        <div className="mt-2 flex flex-wrap gap-2">
          {COLORS.map((color) => {
            const Icon = color.icon
            const isSelected = selectedColors.includes(color.code)

            return (
              <button
                key={color.code}
                type="button"
                onClick={() => handleColorToggle(color.code)}
                className={cx(
                  "size-10 rounded-full flex items-center justify-center transition-all",
                  color.bg,
                  "text-black",
                  isSelected
                    ? "ring-2 ring-ring ring-offset-2 ring-offset-background scale-110"
                    : "opacity-50 hover:opacity-75",
                  "focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:outline-none"
                )}
                title={color.name}
              >
                <Icon />
              </button>
            )
          })}
        </div>
      </div>

      {selectedColors.length > 0 && (
        <div>
          <Label className="text-sm font-medium">Color Match</Label>
          <ToggleGroup
            type="single"
            value={colorMatch}
            onValueChange={(value) => {
              if (value) onColorMatchChange(value as "exact" | "includes")
            }}
            className="mt-2 justify-start"
          >
            <ToggleGroupItem value="includes" className="text-xs">
              Includes these colors
            </ToggleGroupItem>
            <ToggleGroupItem value="exact" className="text-xs">
              Exactly these colors
            </ToggleGroupItem>
          </ToggleGroup>
        </div>
      )}
    </div>
  )
}
