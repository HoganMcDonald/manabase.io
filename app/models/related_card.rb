# frozen_string_literal: true

class RelatedCard < ApplicationRecord
  # Associations
  belongs_to :card, optional: true
  # The related card reference is just a UUID - the actual card might not exist yet
  # We explicitly mark it as optional since cards can reference tokens or cards
  # that haven't been imported yet

  # Constants
  COMPONENT_TYPES = %w[
    token
    meld_part
    meld_result
    combo_piece
    variation_of
    paired_with
  ].freeze

  # Validations
  validates :component, presence: true
  validates :name, presence: true
  validates :type_line, presence: true
  # Use scryfall_id for uniqueness if present, fall back to related_card_id
  validates :scryfall_id, uniqueness: {scope: [:card_id, :component]}, allow_nil: true
  # related_card_id is required and should be unique per card/component pair
  validates :related_card_id, presence: true, uniqueness: {scope: [:card_id, :component]}

  # Scopes
  scope :by_component, ->(component) { where(component: component) }
  scope :tokens, -> { by_component("token") }
  scope :meld_parts, -> { by_component("meld_part") }
  scope :meld_results, -> { by_component("meld_result") }
  scope :combo_pieces, -> { by_component("combo_piece") }
  scope :variations, -> { by_component("variation_of") }
  scope :paired_cards, -> { by_component("paired_with") }

  # Helper methods
  def token?
    component == "token"
  end

  def meld_part?
    component == "meld_part"
  end

  def meld_result?
    component == "meld_result"
  end

  def combo_piece?
    component == "combo_piece"
  end

  def variation?
    component == "variation_of"
  end

  def paired?
    component == "paired_with"
  end

  # Find the actual related card if it exists in the database
  def find_related_card
    # Try to find by scryfall_id first, then by related_card_id, then by oracle_id
    Card.find_by(scryfall_id: scryfall_id) ||
      Card.find_by(scryfall_id: related_card_id) ||
      Card.find_by(oracle_id: related_card_id)
  end

  def related_card_exists?
    find_related_card.present?
  end
end
