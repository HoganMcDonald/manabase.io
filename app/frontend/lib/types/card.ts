export type CardLayouts =
  | "normal"
  | "split"
  | "flip"
  | "transform"
  | "modal_dfc"
  | "meld"
  | "leveler"
  | "class"
  | "saga"
  | "adventure"
  | "battle"
  | "planar"
  | "scheme"
  | "vanguard"
  | "token"
  | "double_faced_token"
  | "emblem"
  | "augment"
  | "host"
  | "art_series"
  | "reversible_card"

export type CardFinish = "nonfoil" | "foil" | "etched"

export interface ImageUris {
  small?: string
  normal?: string
  large?: string
  png?: string
  art_crop?: string
  border_crop?: string
}

export interface CardFace {
  name: string
  mana_cost?: string
  type_line?: string
  oracle_text?: string
  power?: string
  toughness?: string
  loyalty?: string
  colors?: string[]
  imageUris: ImageUris
}

export interface Card {
  id: string
  name: string
  layout: CardLayouts
  finish: CardFinish
  frontFace: CardFace
  backFace?: CardFace
}

// Search API response types
export interface SearchCard {
  id: string
  name: string
  type_line: string
  mana_cost: string | null
  oracle_text?: string
  colors?: string[]
  color_identity?: string[]
  cmc?: number
  layout: string
  power?: string
  toughness?: string
  loyalty?: string
  image_uris?: ImageUris
  finishes?: string[]
  card_faces?: {
    name: string
    mana_cost?: string
    type_line?: string
    oracle_text?: string
    power?: string
    toughness?: string
    loyalty?: string
    colors?: string[]
    image_uris?: ImageUris
  }[]
  score?: number
}

export interface SearchResponse {
  results: SearchCard[]
  total: number
  page: number
  per_page: number
  total_pages: number
}

export interface AutocompleteCard {
  id: string
  name: string
  type_line: string
  mana_cost: string | null
}

/**
 * Transform a search API card result into the Card format expected by MTGCard component
 */
export function transformSearchCardToCard(
  searchCard: SearchCard,
  finish?: CardFinish
): Card {
  const actualFinish: CardFinish =
    finish ??
    (searchCard.finishes?.includes("foil")
      ? "foil"
      : searchCard.finishes?.includes("etched")
        ? "etched"
        : "nonfoil")

  // Handle multi-faced cards
  if (searchCard.card_faces && searchCard.card_faces.length > 0) {
    const frontFace = searchCard.card_faces[0]
    const backFace =
      searchCard.card_faces.length > 1 ? searchCard.card_faces[1] : undefined

    return {
      id: searchCard.id,
      name: searchCard.name,
      layout: searchCard.layout as CardLayouts,
      finish: actualFinish,
      frontFace: {
        name: frontFace.name,
        mana_cost: frontFace.mana_cost,
        type_line: frontFace.type_line,
        oracle_text: frontFace.oracle_text,
        power: frontFace.power,
        toughness: frontFace.toughness,
        loyalty: frontFace.loyalty,
        colors: frontFace.colors,
        imageUris: frontFace.image_uris ?? {},
      },
      backFace: backFace
        ? {
            name: backFace.name,
            mana_cost: backFace.mana_cost,
            type_line: backFace.type_line,
            oracle_text: backFace.oracle_text,
            power: backFace.power,
            toughness: backFace.toughness,
            loyalty: backFace.loyalty,
            colors: backFace.colors,
            imageUris: backFace.image_uris ?? {},
          }
        : undefined,
    }
  }

  // Single-faced cards
  return {
    id: searchCard.id,
    name: searchCard.name,
    layout: searchCard.layout as CardLayouts,
    finish: actualFinish,
    frontFace: {
      name: searchCard.name,
      mana_cost: searchCard.mana_cost ?? undefined,
      type_line: searchCard.type_line,
      oracle_text: searchCard.oracle_text,
      power: searchCard.power,
      toughness: searchCard.toughness,
      loyalty: searchCard.loyalty,
      colors: searchCard.colors,
      imageUris: searchCard.image_uris ?? {},
    },
  }
}
