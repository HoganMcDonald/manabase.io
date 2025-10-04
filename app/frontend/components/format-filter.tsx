import type { FC } from "react"

import { Label } from "@/components/ui/label"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"

interface FormatFilterProps {
  selectedFormats: string[]
  onFormatsChange: (formats: string[]) => void
}

const FORMATS = [
  { value: "standard", label: "Standard" },
  { value: "pioneer", label: "Pioneer" },
  { value: "modern", label: "Modern" },
  { value: "legacy", label: "Legacy" },
  { value: "vintage", label: "Vintage" },
  { value: "commander", label: "Commander" },
  { value: "pauper", label: "Pauper" },
] as const

export const FormatFilter: FC<FormatFilterProps> = ({
  selectedFormats,
  onFormatsChange,
}) => {
  const handleValueChange = (values: string[]) => {
    onFormatsChange(values)
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Format Legality</Label>
        <p className="text-muted-foreground mt-1 text-xs">
          Show cards legal in selected formats
        </p>
      </div>

      <ToggleGroup
        type="multiple"
        value={selectedFormats}
        onValueChange={handleValueChange}
        className="flex-wrap justify-start gap-2"
      >
        {FORMATS.map((format) => (
          <ToggleGroupItem
            key={format.value}
            value={format.value}
            className="text-xs"
          >
            {format.label}
          </ToggleGroupItem>
        ))}
      </ToggleGroup>
    </div>
  )
}
