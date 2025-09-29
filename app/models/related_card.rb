# frozen_string_literal: true

class RelatedCard < ApplicationRecord
  # Associations
  belongs_to :card
  belongs_to :related, class_name: "Card", foreign_key: :related_card_id, optional: true

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
  validates :related_card_id, presence: true
  validates :component, presence: true
  validates :name, presence: true
  validates :type_line, presence: true
  validates :related_card_id, uniqueness: {scope: [:card_id, :component]}

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
    Card.find_by(id: related_card_id) || Card.find_by(oracle_id: related_card_id)
  end

  def related_card_exists?
    find_related_card.present?
  end
end
