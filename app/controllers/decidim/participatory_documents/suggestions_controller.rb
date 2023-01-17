# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionsController < Decidim::ParticipatoryDocuments::ApplicationController
      include FormFactory
      include Paginable
      layout false

      helper_method :section

      def create
        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params(params)

        CreateSuggestion.call(@form, section) do
          on(:ok) do |_suggestion|
            redirect_to(document_section_path(document, section.uid)) && return
          end
          on(:invalid) do
            render partial: "decidim/participatory_documents/suggestions/form", format: [:html], status: :bad_request
          end
        end
      end

      private

      def section
        document.sections.find_by(uid: params[:section_id])
      end
    end
  end
end
