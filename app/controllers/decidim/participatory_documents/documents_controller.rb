# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      helper Decidim::LayoutHelper

      before_action :append_storage_host_to_csp, only: [:pdf_viewer]

      def pdf_viewer
        render layout: false
      end
    end
  end
end
