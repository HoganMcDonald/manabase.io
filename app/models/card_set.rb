# frozen_string_literal: true

class CardSet < ApplicationRecord
  # Associations
  has_many :card_printings, dependent: :destroy
  has_many :cards, through: :card_printings

  # Validations
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :set_type, presence: true

  # Scopes
  scope :released, -> { where.not(released_at: nil).order(released_at: :desc) }
  scope :upcoming, -> { where("released_at > ?", Date.current).order(:released_at) }
  scope :by_type, ->(type) { where(set_type: type) }
  scope :core_sets, -> { by_type("core") }
  scope :expansions, -> { by_type("expansion") }
  scope :masters_sets, -> { by_type("masters") }
  scope :draft_innovation, -> { by_type("draft_innovation") }
  scope :supplemental, -> { where(set_type: %w[commander planechase archenemy vanguard]) }
  scope :digital_only, -> { where(digital: true) }
  scope :paper_only, -> { where(digital: false) }

  # Standard-legal sets (roughly last 2 years of core/expansion sets)
  scope :standard_legal, -> {
    where(set_type: %w[core expansion])
      .where("released_at >= ?", 2.years.ago)
      .where("released_at <= ?", Date.current)
  }

  # Helper methods
  def released?
    released_at.present? && released_at <= Date.current
  end

  def upcoming?
    released_at.present? && released_at > Date.current
  end

  def card_count
    card_printings.count
  end

  def unique_cards_count
    cards.distinct.count
  end

  def standard_legal?
    %w[core expansion].include?(set_type) &&
      released_at >= 2.years.ago &&
      released_at <= Date.current
  end
end
