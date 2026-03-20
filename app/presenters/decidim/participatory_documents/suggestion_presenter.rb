# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionPresenter < Decidim::ResourcePresenter
      def suggestion
        __getobj__
      end

      def title(html_escape: false, all_locales: false)
        return unless suggestion

        super(suggestion.body, html_escape, all_locales)
      end
    end
  end
end
