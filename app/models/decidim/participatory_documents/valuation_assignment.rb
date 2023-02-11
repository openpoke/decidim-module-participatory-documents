# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class ValuationAssignment < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :suggestion, foreign_key: "decidim_participatory_documents_suggestion_id", class_name: "Decidim::ParticipatoryDocuments::Suggestion"
      belongs_to :valuator_role, polymorphic: true

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::ValuationAssignmentPresenter
      end

      def valuator
        valuator_role.user
      end
    end
  end
end
