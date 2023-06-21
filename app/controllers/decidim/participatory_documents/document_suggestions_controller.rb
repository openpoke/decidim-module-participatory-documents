# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentSuggestionsController < Decidim::ParticipatoryDocuments::ApplicationController
      include FormFactory
      include Paginable

      helper_method :section, :suggestions
      layout false

      def index
        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params({})
      end

      def create
        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params(params).with_context(current_component: current_component)

        CreateSuggestion.call(@form, section) do
          on(:ok) do |_suggestion|
            redirect_to(document_suggestions_path(document)) && return
          end
          on(:invalid) do
            render template: "decidim/participatory_documents/document_suggestions/index", format: [:html], status: :bad_request
          end
        end
      end

      private

      def suggestions
        @suggestions ||= section.suggestions.where(author: current_user).order(created_at: :asc)
      end

      def section
        document
      end
    end
  end
end
