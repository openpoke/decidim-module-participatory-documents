# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      helper_method :document

      def index; end

      def pdf_viewer
        render layout: false
      end

      def document
        @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
      end
    end
  end
end
