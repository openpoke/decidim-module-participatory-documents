# frozen_string_literal: true

module Decidim
  # This namespace holds the logic of the `decidim-participatory_documents` module.
  module ParticipatoryDocuments
    include ActiveSupport::Configurable

    # Public: The maximum length of any text field (body, answers, etc) to export.
    # Defaults to 50. Set to 0 to export the full text.
    config_accessor :max_export_text_length do
      50
    end

    # Public: The minimum length of a suggestion to be considered valid.
    config_accessor :min_suggestion_length do
      5
    end

    # Public: The maximum length of a suggestion to be considered valid.
    config_accessor :max_suggestion_length do
      500
    end
  end
end

require "decidim/participatory_documents/engine"
require "decidim/participatory_documents/admin"
require "decidim/participatory_documents/admin_engine"
require "decidim/participatory_documents/component"
