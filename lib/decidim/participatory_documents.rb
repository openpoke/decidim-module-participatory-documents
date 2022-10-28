# frozen_string_literal: true

module Decidim
  # This namespace holds the logic of the `decidim-participatory_documents` module.
  module ParticipatoryDocuments
    include ActiveSupport::Configurable

    config_accessor :content_type_allowlist do
      %w(
        application/vnd.oasis.opendocument
        application/vnd.ms-*
        application/msword
        application/vnd.ms-word
        application/vnd.openxmlformats-officedocument
        application/vnd.oasis.opendocument
        application/pdf
        application/rtf
        text/plain
      )
    end
  end
end

require "decidim/participatory_documents/engine"
require "decidim/participatory_documents/admin"
require "decidim/participatory_documents/admin_engine"
require "decidim/participatory_documents/component"
