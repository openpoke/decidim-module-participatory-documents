# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This class serializes a Suggestion so can be exported to CSV, JSON or other
    # formats.
    class MySuggestionSerializer < SuggestionSerializer
      # Public: Exports a hash with the serialized data for this suggestion.
      def serialize
        super.except(:state, :evaluators).merge(answer: (answer_text(suggestion) if suggestion.published_answer?))
      end
    end
  end
end
