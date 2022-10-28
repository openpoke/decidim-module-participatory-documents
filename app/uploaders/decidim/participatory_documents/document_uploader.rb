# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentUploader < Decidim::ApplicationUploader
      def content_type_allowlist
        Decidim::ParticipatoryDocuments.content_type_allowlist
      end
    end
  end
end
