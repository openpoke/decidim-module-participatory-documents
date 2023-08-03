# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class PublishAnswers < Decidim::Command
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
            suggestion.assign_attributes(answered_at: Time.current, answer_is_published: true)

            if suggestion.answer_is_published_changed?
              Decidim.traceability.perform_action!("publish_answer", suggestion, user) { suggestion.save! }
              notify_user(suggestion)
            end
          end

          broadcast(:ok)
        end

        private

        def notify_user(suggestion)
          suggestion.reload
          return unless suggestion.has_answer?

          NotifySuggestionAnswer.call(suggestion, nil)
        end

        attr_reader :component, :user, :suggestion_ids

        def suggestions
          @suggestions || Decidim::ParticipatoryDocuments::Suggestion
            # .not_published
            # .having_text_answer
            .where(id: suggestion_ids)
        end
      end
    end
  end
end
