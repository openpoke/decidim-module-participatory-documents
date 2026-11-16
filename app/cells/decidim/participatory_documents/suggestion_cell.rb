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

      def author_cell
        cell("decidim/participatory_documents/suggestion_author", model)
      end

      protected

      def has_answer?
        model.published_answer?
      end
    end
  end
end
