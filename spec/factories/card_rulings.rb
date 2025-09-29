# frozen_string_literal: true

FactoryBot.define do
  factory :card_ruling do
    association :card
    sequence(:scryfall_ruling_id) { |n| "00000000-0000-0000-0000-#{n.to_s.rjust(12, '0')}" }
    source { "wotc" }
    published_at { Date.today - 7.days }
    comment { "This ability triggers when the creature enters the battlefield from any zone." }

    trait :gatherer do
      source { "gatherer" }
    end

    trait :recent do
      published_at { Date.today }
    end

    trait :old do
      published_at { 5.years.ago }
    end
  end
end
