# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class EvaluationAssignment < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :suggestion, foreign_key: "decidim_participatory_documents_suggestion_id", class_name: "Decidim::ParticipatoryDocuments::Suggestion"
      belongs_to :evaluator_role, polymorphic: true

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::EvaluationAssignmentPresenter
      end

      def evaluator
        evaluator_role.user
      end
    end
  end
end
