# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SectionsController < Decidim::ParticipatoryDocuments::ApplicationController
      include FormFactory
      include Paginable

      helper_method :section, :suggestions
      layout false, only: [:show]
      delegate :suggestions, to: :section

      def show
        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params({})
      end

      private

      def section
        @section ||= document.sections.find_by!(uid: params[:id])
      end
    end
  end
end
