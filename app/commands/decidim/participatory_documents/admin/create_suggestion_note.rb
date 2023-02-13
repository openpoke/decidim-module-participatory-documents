# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateSuggestionNote < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # suggestion - the suggestion to relate.
        def initialize(form, suggestion)
          @form = form
          @suggestion = suggestion
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the note proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_suggestion_note
          # notify_admins_and_valuators

          broadcast(:ok, suggestion_note)
        end

        private

        attr_reader :form, :suggestion_note, :suggestion

        def create_suggestion_note
          @suggestion_note = Decidim.traceability.create!(
            SuggestionNote,
            form.current_user,
            {
              body: form.body,
              suggestion: suggestion,
              author: form.current_user
            }
          )
        end
      end
    end
  end
end
