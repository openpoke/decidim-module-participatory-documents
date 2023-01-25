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

      def humanize_suggestion_state
        I18n.t(model.state, scope: "decidim.participatory_documents.suggestions.answers")
      end

      def suggestion_state_badge_css_class
        case model.state
        when "accepted"
          "text-success"
        when "rejected"
          "text-alert"
        when "evaluating"
          "text-warning"
        when "withdrawn"
          "text-alert"
        else
          "text-info"
        end
      end

      protected

      delegate :answer_is_draft?, to: :model
      def has_answer?
        return false if answer_is_draft?
        return false if %w(not_answered withdrawn).include?(model.state)
        return false unless model.answered?

        true
      end
    end
  end
end
