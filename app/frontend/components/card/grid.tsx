import type { FC } from "react"

import type { Card } from "@/lib/types/card"

import { MTGCard } from "./mtg-card"

interface CardGridProps {
  heading?: string
  cards: Card[]
}

export const CardGrid: FC<CardGridProps> = ({ cards, heading }) => {
  return (
    <div className="flex flex-col mb-10">
      {heading && <h3 className="mb-4 text-xl font-semibold">{heading}</h3>}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {cards.map((card) => (
          <MTGCard card={card} key={card.id} focus={true} />
        ))}
      </div>
    </div>
  )
}
