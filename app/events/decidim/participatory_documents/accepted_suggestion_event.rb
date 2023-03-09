# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class AcceptedSuggestionEvent < Decidim::ParticipatoryDocuments::BaseSuggestionEvent
      def resource_text
        translated_attribute(resource.answer)
      end
    end
  end
end
