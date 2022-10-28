# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class DocumentsController < Admin::ApplicationController
        include Decidim::ApplicationHelper

        helper_method :document

        def index
          redirect_to(new_document_path) && return unless document.present?
          redirect_to(document_path(document)) && return if current_component.published?
          redirect_to(edit_document_path(document)) && return
        end

        def show

        end
        def new
          enforce_permission_to :create, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::DocumentForm).from_params(params)
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

        def edit
          enforce_permission_to :update, :participatory_document, document: document
          @form = form(Admin::DocumentForm).from_model(document)
        end

        def update
          enforce_permission_to :update, :participatory_document, document: document
          @form = form(Admin::DocumentForm).from_params(params)
          Admin::UpdateDocument.call(@form, document) do
            on(:ok) do |_proposal|
              flash[:notice] = t("documents.update.success", scope: "decidim.participatory_documents.admin")
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = t("documents.update.invalid", scope: "decidim.participatory_documents.admin")
              render :edit
            end
          end
        end

        private

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.where(component: current_component).first
        end
      end
    end
  end
end
