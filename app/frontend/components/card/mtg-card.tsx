"use client"

import { RefreshCw, Undo2 } from "lucide-react"
import { useMemo, useState } from "react"
import type { FC } from "react"
import Tilt from "react-parallax-tilt"

import { useMediaQuery } from "@/hooks/use-media-query"
import type { Card, CardLayouts } from "@/lib/types/card"
import { cn } from "@/lib/utils"

const LayoutToggle = ({
  type,
  onClick,
}: { type: "rotate" | "flip"; onClick: () => void }) => {
  return (
    <button
      onClick={onClick}
      type="button"
      className="absolute flex items-center justify-center right-5 top-3/4 -translate-y-1/2 bg-indigo-600/30 rounded-full size-24 backdrop-blur-sm supports-[backdrop-filter]:bg-indigo-600/30 transition-all shadow-2xl shadow-slate-600 hover:backdrop-blur-[1px] cursor-pointer"
    >
      {type === "rotate" && <RefreshCw size={48} color="white" />}
      {type === "flip" && <Undo2 size={40} color="white" />}
    </button>
  )
}

const FoilOverlay: FC = () => {
  return (
    <div
      className="w-full h-full absolute mix-blend-multiply leading-none"
      style={{
        backgroundSize: "100% 100%",
        backgroundPosition:
          "0px 0px,0px 0px,0px 0px,0px 0px,0px 0px,0px 0px,0px 0px,0px 0px,0px 0px,0px 0px,0px 0px",
        backgroundImage: `
          radial-gradient(18% 28% at 24% 50%, #A4ECFAFF 7%, #073AFF00 100%),
          radial-gradient(18% 28% at 18% 71%, #FFFFFF59 6%, #073AFF00 100%),
          radial-gradient(70% 53% at 36% 76%, #73F2FFFF 0%, #073AFF00 100%),
          radial-gradient(42% 53% at 15% 94%, #FFFFFFFF 7%, #073AFF00 100%),
          radial-gradient(42% 53% at 34% 72%, #6D6EFFF5 7%, #073AFF00 100%),
          radial-gradient(18% 28% at 35% 87%, #FFFFFFFF 7%, #073AFF00 100%),
          radial-gradient(31% 43% at 7% 98%, #FFFFFFFF 24%, #073AFF00 100%),
          radial-gradient(21% 37% at 72% 23%, #D3FF6D9C 24%, #073AFF00 100%),
          radial-gradient(35% 56% at 91% 74%, #8A4FFFF5 9%, #073AFF00 100%),
          radial-gradient(74% 86% at 67% 38%, #6DFFAEF5 24%, #073AFF00 100%),
          linear-gradient(125deg, #FF514EFF 1%, #FCAD00FF 100%)
`,
      }}
    />
  )
}

const EtchedOverlay: FC = () => {
  return (
    <div
      className="w-full h-full absolute mix-blend-overlay leading-none"
      style={{
        backgroundSize: "100% 100%, 200% 200%, 150% 150%",
        backgroundPosition: "0% 0%, 25% 25%, 75% 75%",
        backgroundImage: `
          radial-gradient(circle at 30% 40%, rgba(255, 215, 0, 0.3) 0%, transparent 50%),
          radial-gradient(circle at 70% 60%, rgba(255, 20, 147, 0.25) 0%, transparent 40%),
          radial-gradient(circle at 50% 20%, rgba(138, 43, 226, 0.2) 0%, transparent 60%),
          radial-gradient(ellipse at 20% 80%, rgba(0, 255, 127, 0.15) 0%, transparent 45%),
          radial-gradient(ellipse at 80% 30%, rgba(255, 69, 0, 0.2) 0%, transparent 55%),
          linear-gradient(45deg,
            rgba(255, 215, 0, 0.1) 0%,
            rgba(255, 20, 147, 0.08) 25%,
            rgba(138, 43, 226, 0.06) 50%,
            rgba(0, 255, 127, 0.08) 75%,
            rgba(255, 69, 0, 0.1) 100%
          ),
          repeating-linear-gradient(
            90deg,
            transparent 0px,
            rgba(255, 255, 255, 0.03) 1px,
            transparent 2px,
            transparent 6px
          ),
          repeating-linear-gradient(
            0deg,
            transparent 0px,
            rgba(255, 255, 255, 0.02) 1px,
            transparent 2px,
            transparent 8px
          )
        `,
      }}
    />
  )
}

enum TiltAngle {
  Default = 4,
  Selected = 7,
  Zoomed = 8,
  Mobile = 0,
}

interface MTGCardProps {
  card: Card
  focus?: boolean
  selected?: boolean
  onClick?: () => void
}

export const MTGCard: FC<MTGCardProps> = ({
  card,
  focus = false,
  selected = false,
  onClick,
}) => {
  const [visibleFace, setVisibleFace] = useState<"front" | "back">("front")
  const [orientation, setOrientation] = useState<"portrait" | "landscape">(
    "portrait",
  )

  const { isMedium } = useMediaQuery()
  const isMobile = !isMedium

  const imageUris = useMemo(() => {
    if (visibleFace === "front") {
      return card.frontFace.imageUris
    }
    return card.backFace?.imageUris ?? card.frontFace.imageUris
  }, [visibleFace, card.frontFace.imageUris, card.backFace?.imageUris])

  const maxTiltAngle = useMemo(() => {
    if (focus) {
      return TiltAngle.Zoomed
    }
    if (isMobile) {
      return TiltAngle.Mobile
    }
    return TiltAngle.Default
  }, [focus, isMobile])

  const glareSettings = useMemo(() => {
    if (card.finish === "etched") {
      return {
        glareColor: "rgba(255, 215, 0, 0.3)",
        glareMaxOpacity: 0.4,
        glarePosition: "all" as const,
      }
    }
    if (card.finish === "foil") {
      return {
        glareColor: "rgba(255, 255, 255, 0.5)",
        glareMaxOpacity: 0.7,
        glarePosition: "bottom" as const,
      }
    }
    return {
      glareColor: "rgba(255, 255, 255, 0)",
      glareMaxOpacity: 0,
      glarePosition: "bottom" as const,
    }
  }, [card.finish])

  const toggleType = useMemo(() => {
    const flipTypes: CardLayouts[] = [
      "modal_dfc",
      "transform",
      "double_faced_token",
      "reversible_card",
    ]

    const rotateTypes: CardLayouts[] = ["split", "battle", "flip"]

    if (flipTypes.includes(card.layout)) {
      return "flip"
    }
    if (rotateTypes.includes(card.layout)) {
      return "rotate"
    }
    return null
  }, [card.layout])

  const spin = () =>
    setOrientation((prev) => (prev === "portrait" ? "landscape" : "portrait"))

  const flip = () =>
    setVisibleFace((prev) => (prev === "front" ? "back" : "front"))

  const handleLayoutToggle = () => {
    if (card.layout === "split") {
      spin()
    }

    if (card.layout === "transform" || card.layout === "modal_dfc") {
      flip()
    }
  }

  return (
    <div className="relative hover:z-10 transition-transform">
      <Tilt
        tiltMaxAngleX={maxTiltAngle}
        tiltMaxAngleY={maxTiltAngle}
        glareColor={glareSettings.glareColor}
        glareMaxOpacity={glareSettings.glareMaxOpacity}
        glarePosition={glareSettings.glarePosition}
        glareEnable={card.finish === "foil" || card.finish === "etched"}
        gyroscope={isMobile}
        className={cn("overflow-hidden aspect-[2.5/3.5] rounded-[5%/3.6%]", {
          "outline outline-offset-4 outline-blue-400 outline-4": selected,
          "cursor-pointer": !!onClick,
        })}
      >
        {card.finish === "foil" && <FoilOverlay />}
        {card.finish === "etched" && <EtchedOverlay />}
        <div
          onClick={() => onClick?.()}
          onKeyDown={(e) => {
            if (e.key === "Enter" || e.key === " ") {
              onClick?.()
            }
          }}
          className={cn(
            "bg-slate-950 leading-none w-full h-full rounded-[5%/3.6%] overflow-hidden transition-transform",
            {
              "rotate-90": orientation === "landscape",
            },
          )}
        >
          {imageUris.normal ? (
            <img
              className="w-full h-full"
              srcSet={`${imageUris.small}, ${imageUris.normal} 2x, ${imageUris.large} 3x`}
              src={imageUris.large}
              alt={card.name}
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-slate-800 text-slate-400 text-center p-4">
              <div>
                <div className="text-sm font-medium mb-2">{card.name}</div>
                <div className="text-xs">Image not available</div>
              </div>
            </div>
          )}
        </div>
      </Tilt>
      {focus && toggleType && (
        <LayoutToggle type={toggleType} onClick={handleLayoutToggle} />
      )}
    </div>
  )
}
