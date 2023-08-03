# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionCell < Decidim::ViewModel
      include Decidim::ParticipatoryDocuments::Admin::SuggestionHelper
      include Decidim::IconHelper
      include Decidim::Admin::IconLinkHelper

      def show
        render
      end

      def admin_answer
        render
      end

      def answered_at
        return unless has_answer?

        l(model.answered_at, format: :decidim_short)
      end

      def humanize_suggestion_state
        I18n.t(model.state, scope: "decidim.participatory_documents.suggestions.answers")
      end

      def author_cell
        cell("decidim/participatory_documents/suggestion_author", model)
      end

      protected

      def has_answer?
        return false if %w(not_answered withdrawn).include?(model.state)

        model.answered? && model.answer_is_published?
      end
    end
  end
end
