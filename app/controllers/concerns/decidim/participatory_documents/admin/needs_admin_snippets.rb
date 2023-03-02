# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This module contains adds custom javascript and css for the admin controllers related to participatory documents
      module NeedsAdminSnippets
        extend ActiveSupport::Concern

        included do
          before_action :add_snippets

          private

          def add_snippets
            return unless respond_to?(:snippets)

            snippets.add(:head, helpers.stylesheet_pack_tag("decidim_participatory_documents_admin"))
            snippets.add(:head, helpers.javascript_pack_tag("decidim_participatory_documents_admin"))
          end
        end
      end
    end
  end
end
