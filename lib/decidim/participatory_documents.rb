# frozen_string_literal: true

module Decidim
  # This namespace holds the logic of the `decidim-participatory_documents` module.
  module ParticipatoryDocuments
    class << self
      def config = self

      def configure
        yield self
      end

      attr_writer :antivirus_enabled

      def antivirus_enabled
        return @antivirus_enabled unless @antivirus_enabled.nil?

        defined?(AntivirusValidator) ? true : false
      end
    end

    # Public: The maximum length of any text field (body, answers, etc) to export.
    # Defaults to 0, which exports the full text.
    mattr_accessor :max_export_text_length, default: ENV.fetch("MAX_EXPORT_TEXT_LENGTH", 0).to_i

    # Public: The minimum length of a suggestion to be considered valid.
    # This setting is configurable per-component by admins
    mattr_accessor :min_suggestion_length, default: ENV.fetch("MIN_SUGGESTION_LENGTH", 5).to_i

    # Public: The maximum length of a suggestion to be considered valid.
    # This setting is configurable per-component by admins
    mattr_accessor :max_suggestion_length, default: ENV.fetch("MAX_SUGGESTION_LENGTH", 1000).to_i

    # PDF.js URL to download the prebuilt version of PDF.js
    mattr_accessor :pdfjs_url, default: "https://github.com/mozilla/pdf.js/releases/download/v5.2.133/pdfjs-5.2.133-dist.zip"

    # SHA256 checksum of the file downloaded from pdfjs_url. Set it to nil to skip the verification.
    mattr_accessor :pdfjs_checksum, default: "82c6de8955024d1733dfb74aa50bb6e2f210dbb479c90e2c29fe2bbd4ff446dc"
  end
end

require "decidim/participatory_documents/engine"
require "decidim/participatory_documents/admin"
require "decidim/participatory_documents/admin_engine"
require "decidim/participatory_documents/component"
