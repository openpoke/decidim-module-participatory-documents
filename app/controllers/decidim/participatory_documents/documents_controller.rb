# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      include NeedsPdfDocument
      helper Decidim::LayoutHelper

      def index; end

      def pdf_viewer
        render layout: false
      end
    end
  end
end
