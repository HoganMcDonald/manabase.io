# frozen_string_literal: true

class Card < ApplicationRecord
  # Associations
  has_many :card_printings, dependent: :destroy
  has_many :card_sets, through: :card_printings
  has_many :card_faces, -> { order(:face_index) }, dependent: :destroy
  has_many :card_legalities, dependent: :destroy
  has_many :related_cards, dependent: :destroy
  has_many :related_to, class_name: "RelatedCard", foreign_key: :related_card_id

  # OpenSearch indexing callbacks
  after_commit :index_in_opensearch, on: [:create, :update]
  after_commit :remove_from_opensearch, on: :destroy

  # Validations
  validates :oracle_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :cmc, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :type_line, presence: true
  validates :layout, presence: true
  validates :image_status, presence: true

  # Scopes for color identity searches
  scope :commander_legal_for, ->(colors) {
    where("color_identity <@ ?", colors.sort.to_json)
  }

  scope :includes_colors, ->(colors) {
    where("color_identity @> ?", colors.to_json)
  }

  scope :exactly_colors, ->(colors) {
    where("color_identity = ?", colors.sort.to_json)
  }

  scope :colorless, -> { where("color_identity = ?", [].to_json) }
  scope :mono_colored, -> { where("jsonb_array_length(color_identity) = 1") }
  scope :multicolored, -> { where("jsonb_array_length(color_identity) > 1") }

  # Scopes for card types
  scope :creatures, -> { where("type_line ILIKE ?", "%creature%") }
  scope :instants, -> { where("type_line ILIKE ?", "%instant%") }
  scope :sorceries, -> { where("type_line ILIKE ?", "%sorcery%") }
  scope :artifacts, -> { where("type_line ILIKE ?", "%artifact%") }
  scope :enchantments, -> { where("type_line ILIKE ?", "%enchantment%") }
  scope :planeswalkers, -> { where("type_line ILIKE ?", "%planeswalker%") }
  scope :lands, -> { where("type_line ILIKE ?", "%land%") }
  scope :legendary, -> { where("type_line ILIKE ?", "%legendary%") }

  # Scopes for mana value
  scope :cmc_between, ->(min, max) { where(cmc: min..max) }
  scope :cmc_at_most, ->(value) { where("cmc <= ?", value) }
  scope :cmc_exactly, ->(value) { where(cmc: value) }

  # Format legality scopes
  scope :legal_in, ->(format) {
    joins(:card_legalities).where(card_legalities: {format: format, status: "legal"})
  }
  scope :standard_legal, -> { legal_in("standard") }
  scope :pioneer_legal, -> { legal_in("pioneer") }
  scope :modern_legal, -> { legal_in("modern") }
  scope :legacy_legal, -> { legal_in("legacy") }
  scope :vintage_legal, -> { legal_in("vintage") }
  scope :commander_legal, -> { legal_in("commander") }
  scope :pauper_legal, -> { legal_in("pauper") }

  # Search scopes
  scope :name_contains, ->(text) { where("name ILIKE ?", "%#{text}%") }
  scope :oracle_contains, ->(text) { where("oracle_text ILIKE ?", "%#{text}%") }
  scope :type_contains, ->(text) { where("type_line ILIKE ?", "%#{text}%") }

  # Platform availability
  scope :on_arena, -> { where.not(arena_id: nil) }
  scope :on_mtgo, -> { where.not(mtgo_id: nil) }

  # Special characteristics
  scope :with_keywords, ->(keyword) { where("? = ANY(keywords)", keyword) }
  scope :produces_mana, -> { where("jsonb_array_length(produced_mana) > 0") }
  scope :reserved_list, -> { where(reserved: true) }

  # Helper methods
  def multi_faced?
    card_faces.any?
  end

  def color_identity_symbols
    color_identity.join
  end

  def legal_in?(format)
    card_legalities.where(format: format, status: "legal").exists?
  end

  def restricted_in?(format)
    card_legalities.where(format: format, status: "restricted").exists?
  end

  def banned_in?(format)
    card_legalities.where(format: format, status: "banned").exists?
  end

  def mana_value
    cmc.to_i
  end

  def creature?
    type_line.downcase.include?("creature")
  end

  def instant?
    type_line.downcase.include?("instant")
  end

  def sorcery?
    type_line.downcase.include?("sorcery")
  end

  def artifact?
    type_line.downcase.include?("artifact")
  end

  def enchantment?
    type_line.downcase.include?("enchantment")
  end

  def planeswalker?
    type_line.downcase.include?("planeswalker")
  end

  def land?
    type_line.downcase.include?("land")
  end

  def legendary?
    type_line.downcase.include?("legendary")
  end

  private

  def index_in_opensearch
    OpenSearchCardUpdateJob.perform_later(id, "index")
  end

  def remove_from_opensearch
    OpenSearchCardUpdateJob.perform_later(id, "delete")
  end
end
