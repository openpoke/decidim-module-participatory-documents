# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class PublishAnswers < Decidim::Command
        # Public: Initializes the command.
        #
        # component - The component that contains the answers.
        # user - the Decidim::User that is publishing the answers.
        # suggestion_ids - the identifiers of the suggestions with the answers to be published.
        def initialize(component, user, suggestion_ids)
          @component = component
          @user = user
          @suggestion_ids = suggestion_ids
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are not suggestions to publish.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if suggestions.empty?

          suggestions.each do |suggestion|
            Decidim.traceability.perform_action!("publish_answer", suggestion, user) do
              suggestion.update!(answered_at: Time.current, answer_is_published: true)
            end
            NotifySuggestionAnswer.call(suggestion)
          end

          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :suggestion_ids

        def suggestions
          @suggestions ||= document ? document.suggestions_including_sections.where(id: suggestion_ids).select(&:publishable_answer?) : []
        end

        def document
          @document ||= Document.find_by(component:) # rubocop:disable Decidim/OrganizationScopedFinder
        end
      end
    end
  end
end
