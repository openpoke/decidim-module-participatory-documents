# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      helper_method :document, :annotations

      def index; end

      def pdf_viewer
        render layout: false
      end

      def document
        @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
      end

      def annotations
        @annotations ||= Decidim::ParticipatoryDocuments::VisibleAnnotations.for(document, current_user)
      end
    end
  end
end
