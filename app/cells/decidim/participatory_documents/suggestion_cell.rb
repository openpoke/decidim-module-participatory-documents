# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionCell < Decidim::ViewModel
      def show
        render
      end

      def admin_answer
        render
      end

      protected

      delegate :answer_is_draft?, to: :model
      def has_answer?
        return false if answer_is_draft?
        return false if %w(not_answered withdrawn).include?(model.state)
        return false if model.answered_at.blank?

        true
      end
    end
  end
end
