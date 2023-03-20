# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class NotifySuggestionAnswer < Rectify::Command
        # Public: Initializes the command.
        #
        # suggestion - The suggestion to write the answer for.
        # initial_state - The suggestion state before the current process.
        def initialize(suggestion, initial_state)
          @suggestion = suggestion
          @initial_state = initial_state.to_s
        end

        # Executes the command. Broadcasts these events:
        #
        # - :noop when the answer is not published or the state didn't changed.
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          if suggestion.answer_is_published? && state_changed?
            transaction do
              # increment_score
              notify_followers
            end
          end

          broadcast(:ok)
        end

        private

        attr_reader :suggestion, :initial_state

        def notify_followers
          if proposal.accepted?
            publish_event(
              "decidim.events.participatory_documents.suggestion_accepted",
              Decidim::ParticipatoryDocuments::AcceptedSuggestionEvent
            )
          elsif proposal.rejected?
            publish_event(
              "decidim.events.participatory_documents.suggestion_rejected",
              Decidim::ParticipatoryDocuments::RejectedSuggestionEvent
            )
          elsif proposal.evaluating?
            publish_event(
              "decidim.events.participatory_documents.suggestion_evaluating",
              Decidim::ParticipatoryDocuments::EvaluatingSuggestionEvent
            )
          end
        end

        def publish_event(event, event_class)
          Decidim::EventsManager.publish(
            event: event,
            event_class: event_class,
            resource: suggestion,
            affected_users: [author],
            followers: []
          )
        end

        def state_changed?
          initial_state != suggestion.state.to_s
        end
      end
    end
  end
end
