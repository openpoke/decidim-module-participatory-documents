# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller allows admins to manage documents in a participatory process.
      class DocumentsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::ParticipatoryDocuments::Admin::NeedsAdminSnippets

        helper_method :sections

        def index
          redirect_to(document_suggestions_path(document)) && return if document.present? && document.file.attached?
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
          # TODO: before uploading a new PDF, check no participation associated (no boxes/groups created)
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

        def pdf_viewer
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_params({})
          render layout: false
        end

        def edit_pdf
          enforce_permission_to :update, :participatory_document, document: document
        end

        private

        def sections
          @sections ||= document.sections
        end
      end
    end
  end
end
