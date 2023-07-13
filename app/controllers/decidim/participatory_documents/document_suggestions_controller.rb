# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentSuggestionsController < Decidim::ParticipatoryDocuments::ApplicationController
      include FormFactory
      include Paginable

      helper_method :section, :suggestions
      layout false

      def index
        enforce_permission_to :create, :suggestion

        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).instance
      end

      def create
        enforce_permission_to :create, :suggestion

        @form = form(Decidim::ParticipatoryDocuments::SuggestionForm).from_params(params)

        CreateSuggestion.call(@form, section) do
          on(:ok) do |_suggestion|
            redirect_to(document_suggestions_path(document)) && return
          end
          on(:invalid) do |error|
            render template: "decidim/participatory_documents/document_suggestions/index", locals: { error_message: error }, format: [:html], status: :bad_request
          end
        end
      end

      def export
        enforce_permission_to :create, :suggestion

        return render json: { message: t(".empty") }, status: :unprocessable_entity unless all_suggestions.any?

        Decidim::ExportJob.perform_later(current_user, current_component, :suggestions, "Excel", params[:resource_id].presence)

        render json: { message: t(".success", count: all_suggestions&.count, email: current_user&.email) }
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
