import { cx } from "class-variance-authority"
import { useMemo } from "react"

import {
  ColorlessIcon,
  EnergyCounterIcon,
  ForestIcon,
  IslandIcon,
  MountainIcon,
  PhyrexianIcon,
  PlainsIcon,
  SwampIcon,
  TapIcon,
  UntapIcon,
} from "@/components/icon"

enum Colors {
  WHITE = "W",
  BLUE = "U",
  BLACK = "B",
  RED = "R",
  GREEN = "G",
  COLORLESS = "C",
  GENERIC = "X",
  TAP = "T",
  UNTAP = "Q",
  ENERGY = "E",
}

const validColorSet = new Set<string>([
  Colors.WHITE,
  Colors.BLUE,
  Colors.BLACK,
  Colors.RED,
  Colors.GREEN,
  Colors.COLORLESS,
])

const bgColorMap: Partial<Record<Colors, string>> = {
  [Colors.WHITE]: "var(--magic-white-background)",
  [Colors.BLUE]: "var(--magic-blue-background)",
  [Colors.BLACK]: "var(--magic-black-background)",
  [Colors.RED]: "var(--magic-red-background)",
  [Colors.GREEN]: "var(--magic-green-background)",
  [Colors.COLORLESS]: "var(--magic-colorless-background)",
}

function getIcon(color: Colors) {
  switch (color) {
    case Colors.WHITE:
      return PlainsIcon
    case Colors.BLUE:
      return IslandIcon
    case Colors.BLACK:
      return SwampIcon
    case Colors.RED:
      return MountainIcon
    case Colors.GREEN:
      return ForestIcon
    case Colors.COLORLESS:
      return ColorlessIcon
    default:
      return null
  }
}

export function Pip({ pip }: { pip: string }) {
  const pipText = useMemo(() => {
    return pip.replace(/{|}/g, "")
  }, [pip])

  const color = useMemo(() => {
    const c = pipText.split("/")[0]
    const num = Number.parseInt(c)
    if (!Number.isNaN(num)) {
      return Colors.GENERIC
    }
    return c as Colors
  }, [pipText])

  const modifier = useMemo(() => {
    return pipText.split("/")[1]
  }, [pipText])

  const phyrexian = modifier === "P"

  // Handle generic/color hybrid mana
  if (color === Colors.GENERIC && modifier && validColorSet.has(modifier)) {
    return (
      <GenericColorHybrid number={pipText.split("/")[0]} color={modifier} />
    )
  }

  if (modifier && validColorSet.has(modifier)) {
    return <DualPip first={color} second={modifier} />
  }

  switch (color) {
    case Colors.WHITE:
      return <Plains phyrexian={phyrexian} />
    case Colors.BLUE:
      return <Island phyrexian={phyrexian} />
    case Colors.BLACK:
      return <Swamp phyrexian={phyrexian} />
    case Colors.RED:
      return <Mountain phyrexian={phyrexian} />
    case Colors.GREEN:
      return <Forest phyrexian={phyrexian} />
    case Colors.COLORLESS:
      return <Colorless phyrexian={phyrexian} />
    case Colors.GENERIC:
      return <Generic number={pipText} />
    case Colors.TAP:
      return <Tap />
    case Colors.UNTAP:
      return <Untap />
    case Colors.ENERGY:
      return <Energy />
    default:
      return <>{pip}</>
  }
}

// New component for generic/color hybrid mana
function GenericColorHybrid({
  number,
  color,
}: { number: string; color: string }) {
  const colorBg = bgColorMap[color as Colors] ?? "transparent"
  const ColorIcon = getIcon(color as Colors)

  return (
    <span
      className="relative size-4 text-black rounded-full flex items-center justify-center"
      style={{
        background: `linear-gradient(135deg, hsl(var(--magic-colorless-background)) 50%, hsl(${colorBg}) 50%)`,
      }}
    >
      <span className="absolute top-[10%] left-[10%] size-[0.425rem] flex items-center justify-center">
        <span className="text-[0.4rem] font-bold text-black">{number}</span>
      </span>
      <span className="absolute bottom-[10%] right-[10%] size-[0.425rem] flex items-center justify-center">
        {ColorIcon && <ColorIcon />}
      </span>
    </span>
  )
}

function DualPip({ first, second }: { first: string; second: string }) {
  const firstBg = bgColorMap[first as Colors] ?? "transparent"
  const secondBg = bgColorMap[second as Colors] ?? "transparent"
  const FirstIcon = getIcon(first as Colors)
  const SecondIcon = getIcon(second as Colors)

  return (
    <span
      className="relative size-4 text-black rounded-full flex items-center justify-center"
      style={{
        background: `linear-gradient(135deg, hsl(${firstBg}) 50%, hsl(${secondBg}) 50%)`,
      }}
    >
      <span className="absolute top-[10%] left-[10%] size-[0.425rem] flex items-center justify-center">
        {FirstIcon && <FirstIcon />}
      </span>
      <span className="absolute bottom-[10%] right-[10%] size-[0.425rem] flex items-center justify-center">
        {SecondIcon && <SecondIcon />}
      </span>
    </span>
  )
}

function Plains({ phyrexian }: { phyrexian?: boolean }) {
  return (
    <span className="size-4 bg-magic-white-bg text-black rounded-full flex items-center justify-center">
      {phyrexian ? <PhyrexianIcon /> : <PlainsIcon />}
    </span>
  )
}

function Island({ phyrexian }: { phyrexian?: boolean }) {
  return (
    <span className="size-4 bg-magic-blue-bg text-black rounded-full flex items-center justify-center">
      {phyrexian ? <PhyrexianIcon /> : <IslandIcon />}
    </span>
  )
}

function Swamp({ phyrexian }: { phyrexian?: boolean }) {
  return (
    <span className="size-4 bg-magic-black-bg text-black rounded-full flex items-center justify-center">
      {phyrexian ? <PhyrexianIcon /> : <SwampIcon />}
    </span>
  )
}

function Mountain({ phyrexian }: { phyrexian?: boolean }) {
  return (
    <span className="size-4 bg-magic-red-bg text-black rounded-full flex items-center justify-center">
      {phyrexian ? <PhyrexianIcon /> : <MountainIcon />}
    </span>
  )
}

function Forest({ phyrexian }: { phyrexian?: boolean }) {
  return (
    <span className="size-4 bg-magic-green-bg text-black rounded-full flex items-center justify-center">
      {phyrexian ? <PhyrexianIcon /> : <ForestIcon />}
    </span>
  )
}

function Colorless({ phyrexian }: { phyrexian?: boolean }) {
  return (
    <span className="size-4 bg-magic-colorless-bg text-black rounded-full flex items-center justify-center">
      {phyrexian ? <PhyrexianIcon /> : <ColorlessIcon />}
    </span>
  )
}

function Generic({ number }: { number: string }) {
  return (
    <span className="size-4 bg-magic-colorless-bg rounded-full flex items-center justify-center">
      <span className="text-xs font-bold text-black">{number}</span>
    </span>
  )
}

function Tap() {
  return (
    <span className="size-4 bg-magic-colorless-bg text-black rounded-full flex items-center justify-center">
      <TapIcon />
    </span>
  )
}

function Untap() {
  return (
    <span
      className="size-4 text-white rounded-full flex items-center justify-center"
      style={{ backgroundColor: "#231f20" }}
    >
      <UntapIcon />
    </span>
  )
}

function Energy() {
  return (
    <span className="size-4 bg-magic-colorless-bg text-black rounded-full flex items-center justify-center">
      <EnergyCounterIcon />
    </span>
  )
}

export function Pips({
  pips,
  className,
}: {
  pips: string
  className?: string
}) {
  const manaSymbols = useMemo(() => {
    if (!pips) return []
    // Regular expression to match each mana symbol in curly braces
    const regex = /{[^}]+}/g
    const matches = pips.match(regex)
    return matches ?? []
  }, [pips])

  return (
    <div className={cx("inline-flex gap-1 items-center", className)}>
      {manaSymbols.map((manaSymbol, i) => (
        <Pip pip={manaSymbol} key={i + manaSymbol} />
      ))}
    </div>
  )
}

export const TextWithPips = ({ text }: { text: string }) => {
  // Updated regex to also match hybrid mana with numbers like {2/G}
  const regex = /((?:\{(?:\d+(?:\/[A-Za-z]+)?|[A-Za-z]+(?:\/[A-Za-z]+)?)\})+)/g
  const segments = text.split(regex)

  return (
    <span className="text-pip">
      {segments.map((segment, index) => {
        if (segment.match(regex)) {
          return (
            <Pips
              key={`${index}_${segment}`}
              pips={segment}
              className="translate-y-0.5"
            />
          )
        }
        return segment
      })}
    </span>
  )
}
