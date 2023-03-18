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

      def author_cell(reverse_order: false)
        cell("decidim/participatory_documents/suggestion_author", model, reverse_order: reverse_order)
      end

      protected

      def has_answer?
        return false if %w(not_answered withdrawn).include?(model.state)

        model.answered? && model.answer_is_published?
      end
    end
  end
end
