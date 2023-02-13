# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionNote < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      belongs_to :suggestion, class_name: "Decidim::ParticipatoryDocuments::Suggestion", counter_cache: true
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"

      default_scope { order(created_at: :asc) }

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::SuggestionNotePresenter
      end
    end
  end
end
