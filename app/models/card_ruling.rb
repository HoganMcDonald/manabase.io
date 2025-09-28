# frozen_string_literal: true

class CardRuling < ApplicationRecord
  # Note: Rulings are linked by oracle_id, not card id
  # This means rulings apply to all printings of a card

  # Validations
  validates :oracle_id, presence: true
  validates :source, presence: true
  validates :published_at, presence: true
  validates :comment, presence: true

  # Scopes
  scope :by_oracle_id, ->(oracle_id) { where(oracle_id: oracle_id) }
  scope :recent_first, -> { order(published_at: :desc) }
  scope :oldest_first, -> { order(published_at: :asc) }
  scope :by_source, ->(source) { where(source: source) }
  scope :wotc, -> { by_source('wotc') }
  scope :scryfall, -> { by_source('scryfall') }
  scope :since, ->(date) { where('published_at >= ?', date) }
  scope :before, ->(date) { where('published_at <= ?', date) }

  # Class methods to get rulings for a card
  def self.for_card(card)
    by_oracle_id(card.oracle_id).recent_first
  end

  # Instance methods
  def card
    Card.find_by(oracle_id: oracle_id)
  end

  def official?
    source == 'wotc'
  end

  def community?
    source == 'scryfall'
  end

  def age_in_days
    (Date.current - published_at).to_i
  end

  def recent?
    age_in_days <= 90
  end
end