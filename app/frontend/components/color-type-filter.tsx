import type { FC } from "react"

import { Label } from "@/components/ui/label"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"

interface ColorTypeFilterProps {
  colorless?: boolean
  monoColor?: boolean
  multicolor?: boolean
  onColorlessChange: (value: boolean) => void
  onMonoColorChange: (value: boolean) => void
  onMulticolorChange: (value: boolean) => void
}

export const ColorTypeFilter: FC<ColorTypeFilterProps> = ({
  colorless,
  monoColor,
  multicolor,
  onColorlessChange,
  onMonoColorChange,
  onMulticolorChange,
}) => {
  const getSelectedValues = () => {
    const values: string[] = []
    if (colorless) values.push("colorless")
    if (monoColor) values.push("mono")
    if (multicolor) values.push("multi")
    return values
  }

  const handleValueChange = (values: string[]) => {
    onColorlessChange(values.includes("colorless"))
    onMonoColorChange(values.includes("mono"))
    onMulticolorChange(values.includes("multi"))
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Color Type</Label>
      </div>

      <ToggleGroup
        type="multiple"
        value={getSelectedValues()}
        onValueChange={handleValueChange}
        className="flex-wrap justify-start gap-2"
      >
        <ToggleGroupItem value="colorless" className="text-xs">
          Colorless
        </ToggleGroupItem>
        <ToggleGroupItem value="mono" className="text-xs">
          Mono-Color
        </ToggleGroupItem>
        <ToggleGroupItem value="multi" className="text-xs">
          Multicolor
        </ToggleGroupItem>
      </ToggleGroup>
    </div>
  )
}
