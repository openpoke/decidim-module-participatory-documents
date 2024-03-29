# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class PdfDocumentUploader < Decidim::ApplicationUploader
      def content_type_allowlist
        %w(application/pdf)
      end

      def extension_allowlist
        %w(pdf)
      end
    end
  end
end
