import { Minus, Plus } from "lucide-react"
import type { FC } from "react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface PowerToughnessFilterProps {
  powerMin?: number
  powerMax?: number
  toughnessMin?: number
  toughnessMax?: number
  onPowerMinChange: (value?: number) => void
  onPowerMaxChange: (value?: number) => void
  onToughnessMinChange: (value?: number) => void
  onToughnessMaxChange: (value?: number) => void
}

export const PowerToughnessFilter: FC<PowerToughnessFilterProps> = ({
  powerMin,
  powerMax,
  toughnessMin,
  toughnessMax,
  onPowerMinChange,
  onPowerMaxChange,
  onToughnessMinChange,
  onToughnessMaxChange,
}) => {
  const handleChange = (
    value: string,
    onChange: (value?: number) => void
  ) => {
    if (value === "") {
      onChange(undefined)
    } else {
      const num = Number.parseInt(value, 10)
      if (!Number.isNaN(num) && num >= 0) {
        onChange(num)
      }
    }
  }

  const handleIncrement = (
    currentValue: number | undefined,
    onChange: (value?: number) => void
  ) => {
    const newValue = (currentValue ?? 0) + 1
    onChange(newValue)
  }

  const handleDecrement = (
    currentValue: number | undefined,
    onChange: (value?: number) => void
  ) => {
    const current = currentValue ?? 0
    if (current > 0) {
      onChange(current - 1)
    } else {
      onChange(undefined)
    }
  }

  return (
    <div className="space-y-4">
      {/* Power Filter */}
      <div className="space-y-2">
        <Label className="text-sm font-medium">Power</Label>
        <div className="flex items-center gap-4">
          {/* Min Power */}
          <div className="flex-1 space-y-1.5">
            <Label
              htmlFor="power-min"
              className="text-xs text-muted-foreground"
            >
              Minimum
            </Label>
            <div className="flex items-center gap-1">
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() => handleDecrement(powerMin, onPowerMinChange)}
              >
                <Minus className="size-4" />
              </Button>
              <Input
                id="power-min"
                type="number"
                min="0"
                placeholder="0"
                value={powerMin ?? ""}
                onChange={(e) => handleChange(e.target.value, onPowerMinChange)}
                className="h-8 text-center"
              />
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() => handleIncrement(powerMin, onPowerMinChange)}
              >
                <Plus className="size-4" />
              </Button>
            </div>
          </div>

          {/* Max Power */}
          <div className="flex-1 space-y-1.5">
            <Label
              htmlFor="power-max"
              className="text-xs text-muted-foreground"
            >
              Maximum
            </Label>
            <div className="flex items-center gap-1">
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() => handleDecrement(powerMax, onPowerMaxChange)}
              >
                <Minus className="size-4" />
              </Button>
              <Input
                id="power-max"
                type="number"
                min="0"
                placeholder="∞"
                value={powerMax ?? ""}
                onChange={(e) => handleChange(e.target.value, onPowerMaxChange)}
                className="h-8 text-center"
              />
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() => handleIncrement(powerMax, onPowerMaxChange)}
              >
                <Plus className="size-4" />
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Toughness Filter */}
      <div className="space-y-2">
        <Label className="text-sm font-medium">Toughness</Label>
        <div className="flex items-center gap-4">
          {/* Min Toughness */}
          <div className="flex-1 space-y-1.5">
            <Label
              htmlFor="toughness-min"
              className="text-xs text-muted-foreground"
            >
              Minimum
            </Label>
            <div className="flex items-center gap-1">
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() =>
                  handleDecrement(toughnessMin, onToughnessMinChange)
                }
              >
                <Minus className="size-4" />
              </Button>
              <Input
                id="toughness-min"
                type="number"
                min="0"
                placeholder="0"
                value={toughnessMin ?? ""}
                onChange={(e) =>
                  handleChange(e.target.value, onToughnessMinChange)
                }
                className="h-8 text-center"
              />
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() =>
                  handleIncrement(toughnessMin, onToughnessMinChange)
                }
              >
                <Plus className="size-4" />
              </Button>
            </div>
          </div>

          {/* Max Toughness */}
          <div className="flex-1 space-y-1.5">
            <Label
              htmlFor="toughness-max"
              className="text-xs text-muted-foreground"
            >
              Maximum
            </Label>
            <div className="flex items-center gap-1">
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() =>
                  handleDecrement(toughnessMax, onToughnessMaxChange)
                }
              >
                <Minus className="size-4" />
              </Button>
              <Input
                id="toughness-max"
                type="number"
                min="0"
                placeholder="∞"
                value={toughnessMax ?? ""}
                onChange={(e) =>
                  handleChange(e.target.value, onToughnessMaxChange)
                }
                className="h-8 text-center"
              />
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="size-8 p-0"
                onClick={() =>
                  handleIncrement(toughnessMax, onToughnessMaxChange)
                }
              >
                <Plus className="size-4" />
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
