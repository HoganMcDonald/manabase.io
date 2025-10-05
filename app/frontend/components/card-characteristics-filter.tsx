import type { FC } from "react"

import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"

interface CardCharacteristicsFilterProps {
  promo?: boolean
  reprint?: boolean
  digital?: boolean
  oversized?: boolean
  storySpotlight?: boolean
  gameChanger?: boolean
  onPromoChange: (value: boolean) => void
  onReprintChange: (value: boolean) => void
  onDigitalChange: (value: boolean) => void
  onOversizedChange: (value: boolean) => void
  onStorySpotlightChange: (value: boolean) => void
  onGameChangerChange: (value: boolean) => void
}

export const CardCharacteristicsFilter: FC<CardCharacteristicsFilterProps> = ({
  promo,
  reprint,
  digital,
  oversized,
  storySpotlight,
  gameChanger,
  onPromoChange,
  onReprintChange,
  onDigitalChange,
  onOversizedChange,
  onStorySpotlightChange,
  onGameChangerChange,
}) => {
  return (
    <div className="space-y-3">
      <div>
        <Label className="text-sm font-medium">Card Characteristics</Label>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <div className="flex items-center gap-2">
          <Checkbox
            id="char-promo"
            checked={promo ?? false}
            onCheckedChange={(checked) => onPromoChange(checked === true)}
          />
          <Label
            htmlFor="char-promo"
            className="cursor-pointer text-sm font-normal"
          >
            Promo
          </Label>
        </div>

        <div className="flex items-center gap-2">
          <Checkbox
            id="char-reprint"
            checked={reprint ?? false}
            onCheckedChange={(checked) => onReprintChange(checked === true)}
          />
          <Label
            htmlFor="char-reprint"
            className="cursor-pointer text-sm font-normal"
          >
            Reprint
          </Label>
        </div>

        <div className="flex items-center gap-2">
          <Checkbox
            id="char-digital"
            checked={digital ?? false}
            onCheckedChange={(checked) => onDigitalChange(checked === true)}
          />
          <Label
            htmlFor="char-digital"
            className="cursor-pointer text-sm font-normal"
          >
            Digital
          </Label>
        </div>

        <div className="flex items-center gap-2">
          <Checkbox
            id="char-oversized"
            checked={oversized ?? false}
            onCheckedChange={(checked) => onOversizedChange(checked === true)}
          />
          <Label
            htmlFor="char-oversized"
            className="cursor-pointer text-sm font-normal"
          >
            Oversized
          </Label>
        </div>

        <div className="flex items-center gap-2">
          <Checkbox
            id="char-story"
            checked={storySpotlight ?? false}
            onCheckedChange={(checked) =>
              onStorySpotlightChange(checked === true)
            }
          />
          <Label
            htmlFor="char-story"
            className="cursor-pointer text-sm font-normal"
          >
            Story Spotlight
          </Label>
        </div>

        <div className="flex items-center gap-2">
          <Checkbox
            id="char-game-changer"
            checked={gameChanger ?? false}
            onCheckedChange={(checked) =>
              onGameChangerChange(checked === true)
            }
          />
          <Label
            htmlFor="char-game-changer"
            className="cursor-pointer text-sm font-normal"
          >
            Game Changer
          </Label>
        </div>
      </div>
    </div>
  )
}
