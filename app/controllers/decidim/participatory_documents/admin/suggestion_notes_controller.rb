# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionNotesController < Admin::ApplicationController
        helper_method :note

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

        def edit
          enforce_permission_to :edit_note, :suggestion_note, suggestion_note: note
          @notes_form = form(Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm).from_model(note)
        end

        def update
          enforce_permission_to :edit_note, :suggestion_note, suggestion_note: note
          @notes_form = form(Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm).from_params(params)

          Decidim::ParticipatoryDocuments::Admin::UpdateSuggestionNote.call(@notes_form, note) do
            on(:ok) do
              flash[:notice] = I18n.t("suggestion_notes.update.success", scope: "decidim.participatory_documents.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("suggestion_notes.update.invalid", scope: "decidim.participatory_documents.admin")
            end
            redirect_back(fallback_location: decidim_admin.root_path)
          end
        end

        protected

        def suggestion
          @suggestion ||= Decidim::ParticipatoryDocuments::Suggestion.find(params[:suggestion_id])
        end

        def note
          @note ||= Decidim::ParticipatoryDocuments::SuggestionNote.find(params[:id])
        end
      end
    end
  end
end
