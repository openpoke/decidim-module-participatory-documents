# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SuggestionNotesController < Admin::ApplicationController
        def create
          enforce_permission_to(:create, :suggestion_note, suggestion:)
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

        def update
          enforce_permission_to(:edit_note, :suggestion_note, suggestion_note: note, suggestion:)
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
          @suggestion ||= document.suggestions_including_sections.find(params[:suggestion_id])
        end

        def note
          @note ||= suggestion.notes.find(params[:id])
        end

        private

        def skip_manage_component_permission
          %w(create update).include?(action_name) && evaluator_roles.exists?
        end
      end
    end
  end
end
