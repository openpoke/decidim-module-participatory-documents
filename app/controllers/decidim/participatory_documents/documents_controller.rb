# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      helper Decidim::LayoutHelper

      def pdf_viewer
        render layout: false
      end
    end
  end
end
