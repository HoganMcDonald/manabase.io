import { Minus, Plus } from "lucide-react"
import type { FC } from "react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface CmcFilterProps {
  cmcMin?: number
  cmcMax?: number
  onCmcMinChange: (value?: number) => void
  onCmcMaxChange: (value?: number) => void
}

export const CmcFilter: FC<CmcFilterProps> = ({
  cmcMin,
  cmcMax,
  onCmcMinChange,
  onCmcMaxChange,
}) => {
  const handleMinIncrement = () => {
    const newValue = (cmcMin ?? 0) + 1
    onCmcMinChange(newValue)
  }

  const handleMinDecrement = () => {
    const currentValue = cmcMin ?? 0
    if (currentValue > 0) {
      onCmcMinChange(currentValue - 1)
    } else {
      onCmcMinChange(undefined)
    }
  }

  const handleMaxIncrement = () => {
    const newValue = (cmcMax ?? 0) + 1
    onCmcMaxChange(newValue)
  }

  const handleMaxDecrement = () => {
    const currentValue = cmcMax ?? 0
    if (currentValue > 0) {
      onCmcMaxChange(currentValue - 1)
    } else {
      onCmcMaxChange(undefined)
    }
  }

  const handleMinChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    if (value === "") {
      onCmcMinChange(undefined)
    } else {
      const num = Number.parseInt(value, 10)
      if (!Number.isNaN(num) && num >= 0) {
        onCmcMinChange(num)
      }
    }
  }

  const handleMaxChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    if (value === "") {
      onCmcMaxChange(undefined)
    } else {
      const num = Number.parseInt(value, 10)
      if (!Number.isNaN(num) && num >= 0) {
        onCmcMaxChange(num)
      }
    }
  }

  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Mana Value (CMC)</Label>
      </div>

      <div className="flex items-center gap-4">
        {/* Min CMC */}
        <div className="flex-1 space-y-1.5">
          <Label htmlFor="cmc-min" className="text-xs text-muted-foreground">
            Minimum
          </Label>
          <div className="flex items-center gap-1">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={handleMinDecrement}
            >
              <Minus className="size-4" />
            </Button>
            <Input
              id="cmc-min"
              type="number"
              min="0"
              placeholder="0"
              value={cmcMin ?? ""}
              onChange={handleMinChange}
              className="h-8 text-center"
            />
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={handleMinIncrement}
            >
              <Plus className="size-4" />
            </Button>
          </div>
        </div>

        {/* Max CMC */}
        <div className="flex-1 space-y-1.5">
          <Label htmlFor="cmc-max" className="text-xs text-muted-foreground">
            Maximum
          </Label>
          <div className="flex items-center gap-1">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={handleMaxDecrement}
            >
              <Minus className="size-4" />
            </Button>
            <Input
              id="cmc-max"
              type="number"
              min="0"
              placeholder="∞"
              value={cmcMax ?? ""}
              onChange={handleMaxChange}
              className="h-8 text-center"
            />
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={handleMaxIncrement}
            >
              <Plus className="size-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
