# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SectionsController < Decidim::ParticipatoryDocuments::ApplicationController
      include FormFactory
      include Paginable

      helper_method :section, :suggestions
      layout false, only: [:show]

      def show
        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params({})
      end

      private

      def suggestions
        @suggestions ||= section.suggestions.where(author: current_user)
      end

      def section
        @section ||= document.sections.find_by!(uid: params[:id])
      end
    end
  end
end
