# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class CreateSuggestion < Rectify::Command
      def initialize(form, suggestable)
        @form = form
        @suggestable = suggestable
      end

      def call
        return broadcast(:invalid) if form.invalid?

        begin
          transaction do
            create_suggestion
          end
          broadcast(:ok, suggestion)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form, :suggestion, :suggestable

      def create_suggestion
        @suggestion = Decidim.traceability.create!(
          Decidim::ParticipatoryDocuments::Suggestion,
          form.current_user,
          { body: { I18n.locale => form.body },
            suggestable: suggestable,
            author: form.current_user },
          visibility: "public-only"
        )
      end
    end
  end
end
