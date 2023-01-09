# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller allows admins to manage documents in a participatory process.
      class DocumentsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        helper Decidim::ParticipatoryDocuments::Admin::DocumentsHelper

        helper_method :document, :zones
        before_action :add_snippets, only: :edit_pdf

        def index; end

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
          @form = form(Decidim::ParticipatoryDocuments::Admin::ZoneForm).from_params({})
          render layout: false
        end

        def edit_pdf
          enforce_permission_to :update, :participatory_document, document: document
        end

        private

        def add_snippets
          return unless respond_to?(:snippets)

          snippets.add(:head, helpers.stylesheet_pack_tag("decidim_participatory_documents_admin"))
          snippets.add(:head, helpers.javascript_pack_tag("decidim_participatory_documents_admin"))
        end

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
        end

        def zones
          @zones ||= Decidim::ParticipatoryDocuments::Section.where(document: document)
        end
      end
    end
  end
end
