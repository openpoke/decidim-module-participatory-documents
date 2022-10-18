# frozen_string_literal: true

require "decidim/participatory_documents/engine"
require "decidim/participatory_documents/admin"
require "decidim/participatory_documents/admin_engine"
require "decidim/participatory_documents/component"

module Decidim
  # This namespace holds the logic of the `decidim-participatory_documents` module.
  module ParticipatoryDocuments
    include ActiveSupport::Configurable
  end
end
