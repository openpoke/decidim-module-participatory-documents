# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class EditSuggestionNoteModalCell < Decidim::ViewModel
      include ActionView::Helpers::FormOptionsHelper
      include Decidim::ParticipatoryDocuments::AdminEngine.routes.url_helpers

      def show
        @suggestion = options[:suggestion]
        render if note
      end

      def note
        model
      end

      def note_body
        model.body
      end

      def modal_id
        options[:modal_id] || "editNoteModal"
      end

      def notes_form
        @notes_form = Decidim::ParticipatoryDocuments::Admin::SuggestionNoteForm.from_model(note)
      end

      def note_path
        document_suggestion_suggestion_note_path(suggestion_id: @suggestion.id, id: note)
      end
    end
  end
end
