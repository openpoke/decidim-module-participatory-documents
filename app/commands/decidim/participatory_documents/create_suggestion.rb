# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class CreateSuggestion < Rectify::Command
      def initialize(form, zone)
        @form = form
        @zone = zone
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
      attr_reader :form, :suggestion

      def create_suggestion
        @suggestion = Decidim.traceability.create!(
          Decidim::ParticipatoryDocuments::Suggestion,
          form.current_user,
          attributes,
          visibility: "public-only"
        )
      end

      def attributes
        {
          description: { I18n.locale => form.description },
          zone: zone,
          author: form.current_user
        }
      end
    end
  end
end
