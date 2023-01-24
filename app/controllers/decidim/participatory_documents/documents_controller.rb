# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class DocumentsController < Decidim::ParticipatoryDocuments::ApplicationController
      helper_method :document

      rescue_from ActiveRecord::RecordNotFound do |_exception|
        flash.now[:alert] = t("documents.missing", scope: "decidim.participatory_documents")
        redirect_to "/404"
      end

      def index
        raise ActiveRecord::RecordNotFound unless document.file.attached?
      end

      def pdf_viewer
        render layout: false
      end

      def document
        @document ||= Decidim::ParticipatoryDocuments::Document.find_by!(component: current_component)
      end
    end
  end
end
