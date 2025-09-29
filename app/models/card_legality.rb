# frozen_string_literal: true

class CardLegality < ApplicationRecord
  # Associations
  belongs_to :card

  # Constants
  FORMATS = %w[
    standard
    future
    historic
    timeless
    gladiator
    pioneer
    explorer
    modern
    legacy
    pauper
    vintage
    penny
    commander
    oathbreaker
    standardbrawl
    brawl
    alchemy
    paupercommander
    duel
    oldschool
    premodern
    predh
  ].freeze

  STATUSES = %w[legal not_legal restricted banned].freeze

  # Validations
  validates :format, presence: true, inclusion: {in: FORMATS}
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :format, uniqueness: {scope: :card_id}

  # Scopes
  scope :by_format, ->(format) { where(format: format) }
  scope :by_status, ->(status) { where(status: status) }
  scope :legal, -> { by_status("legal") }
  scope :banned, -> { by_status("banned") }
  scope :restricted, -> { by_status("restricted") }
  scope :not_legal, -> { by_status("not_legal") }

  # Format group scopes
  scope :eternal_formats, -> { where(format: %w[vintage legacy commander]) }
  scope :rotating_formats, -> { where(format: %w[standard pioneer]) }
  scope :digital_formats, -> { where(format: %w[historic timeless alchemy explorer]) }
  scope :casual_formats, -> { where(format: %w[commander oathbreaker brawl paupercommander]) }

  # Helper methods
  def legal?
    status == "legal"
  end

  def banned?
    status == "banned"
  end

  def restricted?
    status == "restricted"
  end

  def not_legal?
    status == "not_legal"
  end

  def eternal_format?
    %w[vintage legacy commander].include?(format)
  end

  def rotating_format?
    %w[standard pioneer].include?(format)
  end

  def digital_format?
    %w[historic timeless alchemy explorer].include?(format)
  end

  def casual_format?
    %w[commander oathbreaker brawl paupercommander].include?(format)
  end
end
