# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      helper Decidim::LayoutHelper

      before_action :append_storage_host_to_csp, only: :pdf_viewer

      # rubocop:disable Decidim/EnforcePermissionTo
      def pdf_viewer
        raise ActionController::RoutingError, "Not Found" if document.blank?

        render layout: false
      end
      # rubocop:enable Decidim/EnforcePermissionTo
    end
  end
end
