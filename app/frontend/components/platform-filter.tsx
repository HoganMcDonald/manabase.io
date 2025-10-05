import type { FC } from "react"

import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"

interface PlatformFilterProps {
  onArena?: boolean
  onMtgo?: boolean
  onArenaChange: (value: boolean) => void
  onMtgoChange: (value: boolean) => void
}

export const PlatformFilter: FC<PlatformFilterProps> = ({
  onArena,
  onMtgo,
  onArenaChange,
  onMtgoChange,
}) => {
  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Platform Availability</Label>
      </div>

      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <Checkbox
            id="platform-arena"
            checked={onArena ?? false}
            onCheckedChange={(checked) =>
              onArenaChange(checked === true)
            }
          />
          <Label
            htmlFor="platform-arena"
            className="cursor-pointer text-sm font-normal"
          >
            Arena
          </Label>
        </div>

        <div className="flex items-center gap-2">
          <Checkbox
            id="platform-mtgo"
            checked={onMtgo ?? false}
            onCheckedChange={(checked) =>
              onMtgoChange(checked === true)
            }
          />
          <Label
            htmlFor="platform-mtgo"
            className="cursor-pointer text-sm font-normal"
          >
            Magic Online (MTGO)
          </Label>
        </div>
      </div>
    </div>
  )
}
