import { Minus, Plus } from "lucide-react"
import type { FC } from "react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface EdhrecRankFilterProps {
  edhrecRankMin?: number
  edhrecRankMax?: number
  onEdhrecRankMinChange: (value?: number) => void
  onEdhrecRankMaxChange: (value?: number) => void
}

export const EdhrecRankFilter: FC<EdhrecRankFilterProps> = ({
  edhrecRankMin,
  edhrecRankMax,
  onEdhrecRankMinChange,
  onEdhrecRankMaxChange,
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
    onChange: (value?: number) => void,
    step = 100
  ) => {
    const newValue = (currentValue ?? 0) + step
    onChange(newValue)
  }

  const handleDecrement = (
    currentValue: number | undefined,
    onChange: (value?: number) => void,
    step = 100
  ) => {
    const current = currentValue ?? 0
    if (current >= step) {
      onChange(current - step)
    } else if (current > 0) {
      onChange(0)
    } else {
      onChange(undefined)
    }
  }

  return (
    <div className="space-y-2">
      <Label className="text-sm font-medium">EDHREC Rank</Label>
      <p className="text-xs text-muted-foreground">
        Lower rank = more popular (1 is most popular)
      </p>
      <div className="flex items-center gap-4">
        {/* Min Rank */}
        <div className="flex-1 space-y-1.5">
          <Label
            htmlFor="edhrec-min"
            className="text-xs text-muted-foreground"
          >
            Best (Min)
          </Label>
          <div className="flex items-center gap-1">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={() =>
                handleDecrement(edhrecRankMin, onEdhrecRankMinChange)
              }
            >
              <Minus className="size-4" />
            </Button>
            <Input
              id="edhrec-min"
              type="number"
              min="0"
              step="100"
              placeholder="1"
              value={edhrecRankMin ?? ""}
              onChange={(e) =>
                handleChange(e.target.value, onEdhrecRankMinChange)
              }
              className="h-8 text-center"
            />
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={() =>
                handleIncrement(edhrecRankMin, onEdhrecRankMinChange)
              }
            >
              <Plus className="size-4" />
            </Button>
          </div>
        </div>

        {/* Max Rank */}
        <div className="flex-1 space-y-1.5">
          <Label
            htmlFor="edhrec-max"
            className="text-xs text-muted-foreground"
          >
            Worst (Max)
          </Label>
          <div className="flex items-center gap-1">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={() =>
                handleDecrement(edhrecRankMax, onEdhrecRankMaxChange)
              }
            >
              <Minus className="size-4" />
            </Button>
            <Input
              id="edhrec-max"
              type="number"
              min="0"
              step="100"
              placeholder="∞"
              value={edhrecRankMax ?? ""}
              onChange={(e) =>
                handleChange(e.target.value, onEdhrecRankMaxChange)
              }
              className="h-8 text-center"
            />
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="size-8 p-0"
              onClick={() =>
                handleIncrement(edhrecRankMax, onEdhrecRankMaxChange)
              }
            >
              <Plus className="size-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
