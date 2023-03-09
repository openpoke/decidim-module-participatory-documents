# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      include NeedsPdfDocument
      helper Decidim::LayoutHelper

      before_action do
        raise ActiveRecord::RecordNotFound unless document.present? && document.file.attached?
      end

      rescue_from ActiveRecord::RecordNotFound do |_exception|
        flash.now[:alert] = t("documents.missing", scope: "decidim.participatory_documents")
        redirect_to "/404"
      end

      def index; end

      def pdf_viewer
        render layout: false
      end
    end
  end
end
