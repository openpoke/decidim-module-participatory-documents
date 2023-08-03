# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This class serializes a Suggestion so can be exported to CSV, JSON or other
    # formats.
    class MySuggestionSerializer < SuggestionSerializer
      # Public: Exports a hash with the serialized data for this suggestion.
      def serialize
        {
          id: suggestion.id,
          body: suggestion_body(suggestion),
          author: suggestion.try(:normalized_author).try(:name),
          state: humanize_suggestion_state(suggestion.state),
          answer: answer_text(suggestion),
          section: section(suggestion),
          submitted_on: submitted_on(suggestion)
        }
      end
    end
  end
end
