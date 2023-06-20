# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller allows admins to manage documents in a participatory process.
      class DocumentsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include NeedsAdminSnippets

        helper Decidim::LayoutHelper
        helper_method :sections

        before_action except: [:index, :new, :create] do
          redirect_to(documents_path) if document.blank?
          redirect_to(edit_document_path(document)) unless document.file.attached?
        end

        def index
          redirect_to(document_suggestions_path(document)) && return if document.present? && document.file.attached?
        end

        def new
          enforce_permission_to :create, :participatory_document
          @form = form(DocumentForm).from_params(params)
        end

        def create
          enforce_permission_to :create, :participatory_document
          @form = form(DocumentForm).from_params(params)

          CreateDocument.call(@form) do
            on(:ok) do |document|
              flash[:notice] = I18n.t("documents.create.success", scope: "decidim.participatory_documents.admin")
              redirect_to edit_pdf_documents_path(id: document.id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("documents.create.invalid", scope: "decidim.participatory_documents.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :participatory_document, document: document
          @form = form(DocumentForm).from_model(document)
        end

        def update
          enforce_permission_to :update, :participatory_document, document: document
          @form = form(DocumentForm).from_params(params)
          UpdateDocument.call(@form, document) do
            on(:ok) do
              flash[:notice] = t("documents.update.success", scope: "decidim.participatory_documents.admin")
              redirect_to documents_path
            end

            on(:error) do |error|
              flash[:alert] = t("documents.update.error", scope: "decidim.participatory_documents.admin") + " #{error}"
              redirect_to documents_path
            end

            on(:invalid) do
              flash.now[:alert] = t("documents.update.error", scope: "decidim.participatory_documents.admin")
              render :edit
            end
          end
        end

        def pdf_viewer
          @form = form(SectionForm).from_params({})
          render layout: false
        end

        def edit_pdf
          enforce_permission_to :update, :participatory_document, document: document
        end

        private

        def sections
          @sections ||= document&.sections
        end
      end
    end
  end
end
