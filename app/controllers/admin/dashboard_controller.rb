# frozen_string_literal: true

class Admin::DashboardController < InertiaController
  before_action :require_admin

  def index
    @users_count = User.count
    @cards_count = Card.count
    @card_sets_count = CardSet.count
    @card_printings_count = CardPrinting.count
    @card_faces_count = CardFace.count
    @card_rulings_count = CardRuling.count
    @card_legalities_count = CardLegality.count
    @related_cards_count = RelatedCard.count
    @scryfall_syncs_count = ScryfallSync.count
    @recent_users = User.order(created_at: :desc).limit(5)

    render inertia: "admin/dashboard", props: {
      stats: {
        users_count: @users_count,
        cards_count: @cards_count,
        card_sets_count: @card_sets_count,
        card_printings_count: @card_printings_count,
        card_faces_count: @card_faces_count,
        card_rulings_count: @card_rulings_count,
        card_legalities_count: @card_legalities_count,
        related_cards_count: @related_cards_count,
        scryfall_syncs_count: @scryfall_syncs_count
      },
      recent_users: @recent_users.map { |user|
        {
          id: user.id,
          name: user.name,
          email: user.email,
          created_at: user.created_at.strftime("%B %d, %Y"),
          verified: user.verified,
          admin: user.admin
        }
      },
      sync_status: ScryfallSync::VALID_SYNC_TYPES.map { |sync_type|
        sync = ScryfallSync.by_type(sync_type).order(created_at: :desc).first
        if sync
          {
            sync_type: sync.sync_type,
            status: sync.status,
            version: sync.version,
            completed_at: sync.completed_at&.strftime("%B %d, %Y %H:%M"),
            processing_status: sync.processing_status,
            total_records: sync.total_records,
            processed_records: sync.processed_records
          }
        else
          {
            sync_type: sync_type,
            status: "never_synced",
            version: nil,
            completed_at: nil,
            processing_status: nil,
            total_records: nil,
            processed_records: nil
          }
        end
      }
    }
  end
end
