# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This module adds custom javascript and css for the admin controllers related to participatory documents
      module NeedsAdminSnippets
        extend ActiveSupport::Concern

        included do
          # before_action :add_snippets

          private

          def add_snippets
            return unless respond_to?(:snippets)

            snippets.add(:head, helpers.stylesheet_pack_tag("decidim_admin_participatory_documents"))
            snippets.add(:foot, helpers.append_javascript_pack_tag("decidim_admin_participatory_documents"))
          end
        end
      end
    end
  end
end
