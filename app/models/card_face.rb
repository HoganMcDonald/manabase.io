# frozen_string_literal: true

class CardFace < ApplicationRecord
  # Associations
  belongs_to :card

  # Validations
  validates :name, presence: true
  validates :face_index, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :face_index, uniqueness: { scope: :card_id }

  # Scopes
  default_scope { order(:face_index) }
  scope :front_faces, -> { where(face_index: 0) }
  scope :back_faces, -> { where(face_index: 1) }
  scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }

  # Helper methods
  def front_face?
    face_index == 0
  end

  def back_face?
    face_index == 1
  end

  def display_name
    printed_name || name
  end

  def image_uri(size = 'normal')
    image_uris&.dig(size) || image_uris&.dig('normal')
  end

  def mana_value
    return 0 unless mana_cost.present?

    # Calculate CMC from mana cost string
    mana_cost.scan(/\d+/).map(&:to_i).sum + mana_cost.scan(/[WUBRG]/).count
  end

  def color_identity_from_mana_cost
    return [] unless mana_cost.present?

    mana_cost.scan(/[WUBRG]/).uniq.sort
  end

  def creature?
    type_line&.downcase&.include?('creature')
  end

  def has_power_toughness?
    power.present? && toughness.present?
  end
end