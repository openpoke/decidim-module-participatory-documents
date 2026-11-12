# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class NotifySuggestionAnswer < Decidim::Command
        # Public: Initializes the command.
        #
        # suggestion - The suggestion to write the answer for.
        def initialize(suggestion)
          @suggestion = suggestion
        end

        # Executes the command. Broadcasts these events:
        #
        # - :invalid when the answer is not published.
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless suggestion.has_answer? && suggestion.published_answer?

          notify_followers

          broadcast(:ok)
        end

        private

        attr_reader :suggestion

        def notify_followers
          publish_event(
            "decidim.events.participatory_documents.suggestion_answered",
            Decidim::ParticipatoryDocuments::SuggestionAnswerEvent
          )
        end

        def publish_event(event, event_class)
          Decidim::EventsManager.publish(
            event:,
            event_class:,
            resource: suggestion,
            affected_users: [suggestion.author]
          )
        end
      end
    end
  end
end
