# frozen_string_literal: true

module Decidim
  # This namespace holds the logic of the `decidim-participatory_documents` module.
  module ParticipatoryDocuments
    include ActiveSupport::Configurable

    # Public: The maximum length of the answer_text fields to export.
    # Defaults to 50. Set to 0 to export the full text.
    config_accessor :max_export_text_length do
      50
    end
  end
end

require "decidim/participatory_documents/engine"
require "decidim/participatory_documents/admin"
require "decidim/participatory_documents/admin_engine"
require "decidim/participatory_documents/component"
