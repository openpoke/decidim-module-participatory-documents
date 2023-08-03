# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This class serializes a Suggestion so can be exported to CSV, JSON or other
    # formats.
    class SuggestionSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ParticipatoryDocuments::Admin::SuggestionHelper
      include ActionView::Helpers::TextHelper

      # Public: Initializes the serializer with a suggestion.
      def initialize(suggestion)
        @suggestion = suggestion
      end

      # Public: Exports a hash with the serialized data for this suggestion.
      def serialize
        {
          id: suggestion.id,
          body: suggestion_body(suggestion),
          author: suggestion.try(:normalized_author).try(:name),
          state: humanize_suggestion_state(suggestion.state),
          answer: answer_text(suggestion),
          section: section(suggestion),
          valuators: suggestion.valuation_assignments.map(&:valuator).map(&:name).join(", "),
          submitted_on: submitted_on(suggestion)
        }
      end

      private

      attr_reader :suggestion

      def section(suggestion)
        if suggestion.suggestable.is_a?(Decidim::ParticipatoryDocuments::Document)
          I18n.t("global", scope: "decidim.participatory_documents.admin.suggestions.suggestion")
        else
          translated_attribute(suggestion.suggestable.title)
        end
      end

      def submitted_on(suggestion)
        I18n.l(suggestion.created_at, format: :decidim_short)
      end

      def prepare_text(suggestion, attribute)
        text_length = Decidim::ParticipatoryDocuments.max_export_text_length

        if text_length.positive?
          truncate(translated_attribute(suggestion.public_send(attribute)), length: text_length)
        else
          translated_attribute(suggestion.public_send(attribute))
        end
      end

      def suggestion_body(suggestion)
        prepare_text(suggestion, :body)
      end

      def answer_text(suggestion)
        prepare_text(suggestion, :answer)
      end
    end
  end
end
