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

      def has_answer?
        return false if %w(not_answered withdrawn).include?(model.state)

        model.answered? && model.answer_is_published?
      end
    end
  end
end
