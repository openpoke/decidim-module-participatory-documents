# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionNotesController < Admin::ApplicationController
        def create
          enforce_permission_to :create, :suggestion_note, suggestion: suggestion
          @form = form(Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm).from_params(params)

          CreateSuggestionNote.call(@form, suggestion) do
            on(:ok) do
              flash[:notice] = I18n.t("suggestion_notes.create.success", scope: "decidim.participatory_documents.admin")
              redirect_to document_suggestion_path(document, suggestion)
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("suggestion_notes.create.error", scope: "decidim.participatory_documents.admin")
              redirect_to document_suggestion_path(document, suggestion)
            end
          end
        end

        protected

        def suggestion
          @suggestion ||= Decidim::ParticipatoryDocuments::Suggestion.find(params[:suggestion_id])
        end
      end
    end
  end
end
