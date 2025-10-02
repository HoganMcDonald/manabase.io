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
    @open_search_syncs_count = OpenSearchSync.count
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
        scryfall_syncs_count: @scryfall_syncs_count,
        open_search_syncs_count: @open_search_syncs_count
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
      },
      open_search_sync_status: open_search_sync_status_data
    }
  end

  private

  def open_search_sync_status_data
    recent_sync = OpenSearchSync.recent.first
    index_stats = Search::CardIndexer.new.index_stats

    {
      recent_sync: recent_sync ? {
        id: recent_sync.id,
        status: recent_sync.status,
        total_cards: recent_sync.total_cards,
        indexed_cards: recent_sync.indexed_cards,
        failed_cards: recent_sync.failed_cards,
        progress_percentage: recent_sync.progress_percentage,
        started_at: recent_sync.started_at&.strftime("%B %d, %Y %H:%M"),
        completed_at: recent_sync.completed_at&.strftime("%B %d, %Y %H:%M"),
        duration_formatted: recent_sync.duration_formatted,
        error_message: recent_sync.error_message
      } : nil,
      index_stats: index_stats
    }
  end
end
