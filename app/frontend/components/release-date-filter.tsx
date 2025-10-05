import type { FC } from "react"

import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface ReleaseDateFilterProps {
  releasedAfter?: string
  releasedBefore?: string
  onReleasedAfterChange: (value?: string) => void
  onReleasedBeforeChange: (value?: string) => void
}

export const ReleaseDateFilter: FC<ReleaseDateFilterProps> = ({
  releasedAfter,
  releasedBefore,
  onReleasedAfterChange,
  onReleasedBeforeChange,
}) => {
  return (
    <div className="space-y-2">
      <Label className="text-sm font-medium">Release Date</Label>
      <div className="flex items-center gap-4">
        {/* After Date */}
        <div className="flex-1 space-y-1.5">
          <Label
            htmlFor="released-after"
            className="text-xs text-muted-foreground"
          >
            From
          </Label>
          <Input
            id="released-after"
            type="date"
            value={releasedAfter ?? ""}
            onChange={(e) =>
              onReleasedAfterChange(e.target.value || undefined)
            }
            className="h-8"
          />
        </div>

        {/* Before Date */}
        <div className="flex-1 space-y-1.5">
          <Label
            htmlFor="released-before"
            className="text-xs text-muted-foreground"
          >
            To
          </Label>
          <Input
            id="released-before"
            type="date"
            value={releasedBefore ?? ""}
            onChange={(e) =>
              onReleasedBeforeChange(e.target.value || undefined)
            }
            className="h-8"
          />
        </div>
      </div>
    </div>
  )
}
