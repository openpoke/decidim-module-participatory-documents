# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      helper_method :annotations

      def index; end

      def pdf_viewer
        render layout: false
      end
      def annotations
        @annotations ||= document.annotations.where(zone_id: document.zones.published)
      end
    end
  end
end
