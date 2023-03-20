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
          broadcast(:invalid) unless suggestion.has_answer? && suggestion.answered? && suggestion.answer_is_published?

          notify_followers

          broadcast(:ok)
        end

        private

        attr_reader :suggestion, :initial_state

        def notify_followers
          if suggestion.accepted?
            publish_event(
              "decidim.events.participatory_documents.suggestion_accepted",
              Decidim::ParticipatoryDocuments::AcceptedSuggestionEvent
            )
          elsif suggestion.rejected?
            publish_event(
              "decidim.events.participatory_documents.suggestion_rejected",
              Decidim::ParticipatoryDocuments::RejectedSuggestionEvent
            )
          elsif suggestion.evaluating?
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
            affected_users: [suggestion.author]
          )
        end
      end
    end
  end
end
