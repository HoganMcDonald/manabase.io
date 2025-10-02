import type { Card } from "@/lib/types/card"

export const goblinRecruiter: Card = {
  id: "1",
  name: "Goblin Recruiter",
  layout: "normal",
  finish: "nonfoil",
  frontFace: {
    name: "Goblin Recruiter",
    mana_cost: "{1}{R}",
    type_line: "Creature — Goblin",
    oracle_text:
      "When Goblin Recruiter enters the battlefield, search your library for any number of Goblin cards and reveal those cards. Shuffle your library, then put them on top of it in any order.",
    power: "1",
    toughness: "1",
    imageUris: {
      small:
        "https://cards.scryfall.io/small/front/6/1/61bd1548-2ffa-4705-ba88-913f37d4ce92.jpg",
      normal:
        "https://cards.scryfall.io/normal/front/6/1/61bd1548-2ffa-4705-ba88-913f37d4ce92.jpg",
      large:
        "https://cards.scryfall.io/large/front/6/1/61bd1548-2ffa-4705-ba88-913f37d4ce92.jpg",
    },
  },
}

export const krenkoSerializedFoil: Card = {
  id: "2",
  name: "Krenko, Mob Boss",
  layout: "normal",
  finish: "foil",
  frontFace: {
    name: "Krenko, Mob Boss",
    mana_cost: "{2}{R}{R}",
    type_line: "Legendary Creature — Goblin Warrior",
    oracle_text:
      "{T}: Create X 1/1 red Goblin creature tokens, where X is the number of Goblins you control.",
    power: "3",
    toughness: "3",
    imageUris: {
      small:
        "https://cards.scryfall.io/small/front/c/d/cd9fec9d-23c8-4d35-97c5-9dd8d5d5113b.jpg",
      normal:
        "https://cards.scryfall.io/normal/front/c/d/cd9fec9d-23c8-4d35-97c5-9dd8d5d5113b.jpg",
      large:
        "https://cards.scryfall.io/large/front/c/d/cd9fec9d-23c8-4d35-97c5-9dd8d5d5113b.jpg",
    },
  },
}

export const gluntchEtched: Card = {
  id: "3",
  name: "Gluntch, the Bestower",
  layout: "normal",
  finish: "etched",
  frontFace: {
    name: "Gluntch, the Bestower",
    mana_cost: "{1}{G}{W}",
    type_line: "Legendary Creature — Jellyfish",
    oracle_text:
      "Flying\nAt the beginning of your end step, choose a player. They put two +1/+1 counters on a creature they control. Choose a second player to draw a card. Then choose a third player to create two Treasure tokens.",
    power: "0",
    toughness: "5",
    imageUris: {
      small:
        "https://cards.scryfall.io/small/front/6/a/6a6a6699-9e27-4aa7-81a3-ae79c1456b34.jpg",
      normal:
        "https://cards.scryfall.io/normal/front/6/a/6a6a6699-9e27-4aa7-81a3-ae79c1456b34.jpg",
      large:
        "https://cards.scryfall.io/large/front/6/a/6a6a6699-9e27-4aa7-81a3-ae79c1456b34.jpg",
    },
  },
}

export const extusMDFC: Card = {
  id: "4",
  name: "Extus, Oriq Overlord // Awaken the Blood Avatar",
  layout: "modal_dfc",
  finish: "nonfoil",
  frontFace: {
    name: "Extus, Oriq Overlord",
    mana_cost: "{1}{R}{W}{B}",
    type_line: "Legendary Creature — Human Warlock",
    oracle_text:
      "Magecraft — Whenever you cast or copy an instant or sorcery spell, return target creature card with mana value 3 or less from your graveyard to the battlefield.",
    power: "2",
    toughness: "5",
    imageUris: {
      small:
        "https://cards.scryfall.io/small/front/b/a/ba09360a-067e-48a5-bdc5-a19fd066a785.jpg",
      normal:
        "https://cards.scryfall.io/normal/front/b/a/ba09360a-067e-48a5-bdc5-a19fd066a785.jpg",
      large:
        "https://cards.scryfall.io/large/front/b/a/ba09360a-067e-48a5-bdc5-a19fd066a785.jpg",
    },
  },
  backFace: {
    name: "Awaken the Blood Avatar",
    mana_cost: "{6}{B}{R}",
    type_line: "Sorcery",
    oracle_text:
      "As an additional cost to cast this spell, you may sacrifice any number of creatures. This spell costs {2} less to cast for each creature sacrificed this way.\nEach opponent sacrifices a creature. Create a 3/6 black and red Avatar creature token with haste and 'Whenever this creature attacks, it deals 3 damage to each opponent.'",
    imageUris: {
      small:
        "https://cards.scryfall.io/small/back/b/a/ba09360a-067e-48a5-bdc5-a19fd066a785.jpg",
      normal:
        "https://cards.scryfall.io/normal/back/b/a/ba09360a-067e-48a5-bdc5-a19fd066a785.jpg",
      large:
        "https://cards.scryfall.io/large/back/b/a/ba09360a-067e-48a5-bdc5-a19fd066a785.jpg",
    },
  },
}

export const dollmakersShopSplit: Card = {
  id: "5",
  name: "Pie // Alive",
  layout: "split",
  finish: "nonfoil",
  frontFace: {
    name: "Pie // Alive",
    mana_cost: "{1}{U} // {3}{G}",
    type_line: "Instant // Sorcery",
    oracle_text:
      "Return target creature to its owner's hand. // Create a 3/3 green Centaur creature token.",
    imageUris: {
      small:
        "https://cards.scryfall.io/small/front/7/5/754e9c3e-8b5b-4d67-ad50-d96c9d3f3cb2.jpg",
      normal:
        "https://cards.scryfall.io/normal/front/7/5/754e9c3e-8b5b-4d67-ad50-d96c9d3f3cb2.jpg",
      large:
        "https://cards.scryfall.io/large/front/7/5/754e9c3e-8b5b-4d67-ad50-d96c9d3f3cb2.jpg",
    },
  },
}
