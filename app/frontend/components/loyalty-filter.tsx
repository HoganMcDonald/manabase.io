import { Minus, Plus } from "lucide-react"
import type { FC } from "react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface LoyaltyFilterProps {
  loyaltyMin?: number
  loyaltyMax?: number
  onLoyaltyMinChange: (value?: number) => void
  onLoyaltyMaxChange: (value?: number) => void
}

export const LoyaltyFilter: FC<LoyaltyFilterProps> = ({
  loyaltyMin,
  loyaltyMax,
  onLoyaltyMinChange,
  onLoyaltyMaxChange,
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
    <div className="space-y-2">
      <Label className="text-sm font-medium">Loyalty</Label>
      <div className="flex items-center gap-4">
        {/* Min Loyalty */}
        <div className="flex-1 space-y-1.5">
          <Label
            htmlFor="loyalty-min"
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
              onClick={() => handleDecrement(loyaltyMin, onLoyaltyMinChange)}
            >
              <Minus className="size-4" />
            </Button>
            <Input
              id="loyalty-min"
              type="number"
              min="0"
              placeholder="0"
              value={loyaltyMin ?? ""}
              onChange={(e) => handleChange(e.target.value, onLoyaltyMinChange)}
              className="h-8 text-center"
            />
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={() => handleIncrement(loyaltyMin, onLoyaltyMinChange)}
            >
              <Plus className="size-4" />
            </Button>
          </div>
        </div>

        {/* Max Loyalty */}
        <div className="flex-1 space-y-1.5">
          <Label
            htmlFor="loyalty-max"
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
              onClick={() => handleDecrement(loyaltyMax, onLoyaltyMaxChange)}
            >
              <Minus className="size-4" />
            </Button>
            <Input
              id="loyalty-max"
              type="number"
              min="0"
              placeholder="∞"
              value={loyaltyMax ?? ""}
              onChange={(e) => handleChange(e.target.value, onLoyaltyMaxChange)}
              className="h-8 text-center"
            />
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={() => handleIncrement(loyaltyMax, onLoyaltyMaxChange)}
            >
              <Plus className="size-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
