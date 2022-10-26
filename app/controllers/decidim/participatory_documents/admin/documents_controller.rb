# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class DocumentsController < Admin::ApplicationController
        include Decidim::ApplicationHelper

        def index;
          redirect_to new_document_path and return if collection.empty?
        end

        def new
          enforce_permission_to :create, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::DocumentForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          enforce_permission_to :create, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::DocumentForm).from_params(params)

          Admin::CreateDocument.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("documents.create.success", scope: "decidim.participatory_documents.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.create.invalid", scope: "decidim.participatory_documents.admin")
              render action: "new"
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::ParticipatoryDocuments::Document.where(component: current_component)
        end
      end
    end
  end
end
