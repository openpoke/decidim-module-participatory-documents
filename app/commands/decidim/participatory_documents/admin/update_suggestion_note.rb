# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # A command with all the business logic when a user updates a suggestion note.
      class UpdateSuggestionNote < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # note - the suggestion note to update.
        def initialize(notes_form, note)
          @notes_form = notes_form
          @note = note
        end

        def call
          return broadcast(:invalid) if notes_form.invalid?

          update_suggestion_note

          broadcast(:ok, note)
        end

        private

        attr_reader :notes_form, :note, :suggestion

        def update_suggestion_note
          note.body = notes_form.body
          note.save!
        end
      end
    end
  end
end
