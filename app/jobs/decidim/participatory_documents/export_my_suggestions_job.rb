# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class ExportMySuggestionsJob < Decidim::ExportJob
      def perform(user, document, format)
        export_manifest = document.component.manifest.export_manifests.find { |manifest| manifest.name == :suggestions }
        collection = export_manifest.collection.call(document.component, user)

        export_data = Decidim::Exporters.find_exporter(format).new(collection, MySuggestionSerializer).export

        ExportMailer.export(user, :suggestions, export_data).deliver_now
      end
    end
  end
end
