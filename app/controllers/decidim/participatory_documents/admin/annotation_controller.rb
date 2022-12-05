# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationController < Admin::ApplicationController
        def destroy; end

        def create
          # enforce_permission_to :create, :participatory_document
          # @form = form(Decidim::ParticipatoryDocuments::Admin::DocumentForm).from_params(params)
          #
          # Admin::CreateDocument.call(@form) do
          #   on(:ok) do
          #     flash[:notice] = I18n.t("documents.create.success", scope: "decidim.participatory_documents.admin")
          #     redirect_to documents_path
          #   end
          #
          #   on(:invalid) do
          #     flash.now[:alert] = I18n.t("documents.create.invalid", scope: "decidim.participatory_documents.admin")
          #     render action: "new"
          #   end
          # end
        end
      end
    end
  end
end
