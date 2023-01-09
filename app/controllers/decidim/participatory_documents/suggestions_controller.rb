# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionsController < Decidim::ParticipatoryDocuments::ApplicationController
      include FormFactory
      include Paginable
      layout false

      helper_method :zone

      def create
        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params(params)

        CreateSuggestion.call(@form, zone) do
          on(:ok) do |suggestion|
            # render "decidim/participatory_documents/zones/show", status: :created
            redirect_to document_zone_path(document, zone.uid) and return
          end
          on(:invalid) do
            render partial: "decidim/participatory_documents/suggestions/form", format: [:html], status: :bad_request
          end
        end
      end

      private
      def zone
        document.zones.published.find_by(id: params[:zone_id])
      end
    end
  end
end
