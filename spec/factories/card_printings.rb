# frozen_string_literal: true

FactoryBot.define do
  factory :card_printing do
    sequence(:scryfall_id) { |n| "00000000-0000-0000-0000-#{n.to_s.rjust(12, '0')}" }
    association :card
    association :card_set
    sequence(:collector_number) { |n| n.to_s }

    uri { "https://api.scryfall.com/cards/#{scryfall_id}" }
    scryfall_uri { "https://scryfall.com/card/#{card_set.code}/#{collector_number}" }
    image_uri_small { "https://cards.scryfall.io/small/front/#{scryfall_id[0]}/#{scryfall_id[1]}/#{scryfall_id}.jpg" }
    image_uri_normal { "https://cards.scryfall.io/normal/front/#{scryfall_id[0]}/#{scryfall_id[1]}/#{scryfall_id}.jpg" }
    image_uri_large { "https://cards.scryfall.io/large/front/#{scryfall_id[0]}/#{scryfall_id[1]}/#{scryfall_id}.jpg" }
    image_uri_png { "https://cards.scryfall.io/png/front/#{scryfall_id[0]}/#{scryfall_id[1]}/#{scryfall_id}.png" }
    image_uri_art_crop { "https://cards.scryfall.io/art_crop/front/#{scryfall_id[0]}/#{scryfall_id[1]}/#{scryfall_id}.jpg" }
    image_uri_border_crop { "https://cards.scryfall.io/border_crop/front/#{scryfall_id[0]}/#{scryfall_id[1]}/#{scryfall_id}.jpg" }

    digital { false }
    highres_image { true }
    reprint { false }
    variation { false }
    story_spotlight { false }
    textless { false }
    booster { true }
    promo { false }

    lang { "en" }
    frame { "2015" }
    full_art { false }
    border_color { "black" }

    price_usd { "1.50" }
    price_usd_foil { "5.00" }
    price_eur { "1.20" }
    price_tix { "0.05" }

    artist { "Test Artist" }
    artist_ids { ["00000000-0000-0000-0000-000000000001"] }
    illustration_id { "00000000-0000-0000-0000-000000000002" }

    trait :foil_only do
      foil { true }
      nonfoil { false }
      price_usd { nil }
      price_usd_foil { "10.00" }
    end

    trait :promo do
      promo { true }
      booster { false }
      collector_number { "P1" }
    end

    trait :showcase do
      frame_effects { ["showcase"] }
      variation { true }
    end
  end
end
