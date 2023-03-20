# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class PublishAnswers < Rectify::Command
        # Public: Initializes the command.
        #
        # component - The component that contains the answers.
        # user - the Decidim::User that is publishing the answers.
        # proposal_ids - the identifiers of the suggestions with the answers to be published.
        def initialize(component, user, suggestion_ids)
          @component = component
          @user = user
          @suggestion_ids = suggestion_ids
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are not proposals to publish.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless suggestions.any?

          suggestions.each do |suggestion|
            transaction do
              mark_suggestion_as_answered(suggestion)
              # notify_suggestion_answer(suggestion)
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :suggestion_ids

        def suggestions
          @suggestions || Decidim::ParticipatoryDocuments::Suggestion
            .not_published
            .having_text_answer
            .where(id: suggestion_ids)
        end

        def mark_suggestion_as_answered(suggestion)
          Decidim.traceability.perform_action!(
            "publish_answer",
            suggestion,
            user
          ) do
            suggestion.update!(answered_at: Time.current, answer_is_published: true)
          end
        end

        def notify_suggestion_answer(suggestion)
          NotifySuggestionAnswer.call(suggestion, nil)
        end
      end
    end
  end
end
