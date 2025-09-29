# frozen_string_literal: true

FactoryBot.define do
  factory :card_set do
    sequence(:scryfall_id) { |n| "00000000-0000-0000-0000-#{n.to_s.rjust(12, '0')}" }
    sequence(:code) { |n| "TST#{n}" }
    sequence(:name) { |n| "Test Set #{n}" }
    uri { "https://api.scryfall.com/sets/#{scryfall_id}" }
    scryfall_uri { "https://scryfall.com/sets/#{code}" }
    search_uri { "https://api.scryfall.com/cards/search?order=set&q=e%3A#{code}&unique=prints" }
    released_at { Date.today - 30.days }
    set_type { "expansion" }
    card_count { 250 }
    digital { false }
    nonfoil_only { false }
    foil_only { false }
    icon_svg_uri { "https://svgs.scryfall.com/sets/#{code}.svg" }

    trait :core_set do
      set_type { "core" }
      card_count { 350 }
    end

    trait :commander do
      set_type { "commander" }
      card_count { 100 }
    end

    trait :digital_only do
      digital { true }
      set_type { "alchemy" }
    end
  end
end
