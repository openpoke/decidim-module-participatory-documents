# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class DocumentsController < Admin::ApplicationController
        include Decidim::Admin::Filterable
        helper Decidim::Meetings::Admin::FilterableHelper

        include Decidim::ApplicationHelper
        helper_method :documents, :document

        def index
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
              flash.now[:alert] = t("documents.update.error", scope: "decidim.participatory_documents.admin")
              render :edit
            end
          end
        end

        private

        def document
          @document ||= collection.find(params[:id])
        end

        def documents
          @documents ||= filtered_collection
        end
        def base_query
          paginate(collection)
        end

        def filters
          []
        end

        def filters_with_values
          {}
        end

        def collection
          @collection ||= Decidim::ParticipatoryDocuments::Document.where(component: current_component)
        end
      end
    end
  end
end
