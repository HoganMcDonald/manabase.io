import type { FC } from "react"

import type { Card } from "@/lib/types/card"

import { MTGCard } from "./mtg-card"

interface CardStackProps {
  heading?: string
  cards: Card[]
}

export const CardStack: FC<CardStackProps> = ({ cards, heading }) => {
  return (
    <div className="flex flex-col max-w-52 break-inside-avoid">
      {heading && <h3 className="mb-4 text-xl font-semibold">{heading}</h3>}
      <div className="grid auto-rows-[2rem]">
        {cards.map((card) => (
          <MTGCard card={card} key={card.id} focus={false} />
        ))}
      </div>
      <div className="aspect-[2.5/3.5] w-full" />
    </div>
  )
}

interface StackGridProps {
  stacks: CardStackProps[]
}

export const StackGrid: FC<StackGridProps> = ({ stacks }) => {
  return (
    <div className="flex flex-col mb-10">
      <div className="columns-1 sm:columns-2 md:columns-3 lg:columns-4 gap-10">
        {stacks.map((stack) => (
          <CardStack key={stack.heading ?? ""} {...stack} />
        ))}
      </div>
    </div>
  )
}
