# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SectionsController < Admin::ApplicationController
        layout false, only: [:new, :edit]
        def destroy
          enforce_permission_to :destroy, :document_section
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_model(section)

          Admin::DestroySection.call(@form, document) do
            on(:ok) do
              render(json: {}, status: :accepted) && return
            end

            on(:invalid) do |code|
              render(json: code, status: :bad_request) && return
            end
          end
        end

        def create
          enforce_permission_to :update, :document_section
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_params(params)

          Admin::CreateSection.call(@form, document) do
            on(:ok) do
              render(json: {}, status: :created) && return
            end

            on(:invalid) do
              render(partial: "form", status: :bad_request) && return
            end
          end
        end

        def update
          enforce_permission_to :update, :document_section
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_params(params)

          Admin::UpdateSection.call(@form, document) do
            on(:ok) do |_annotation|
              render(json: {}, status: :accepted) && return
            end

            on(:invalid) do
              render(partial: "form", status: :bad_request) && return
            end
          end
        end

        def edit
          enforce_permission_to :update, :document_section
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_model(section)

          render partial: "form"
        end

        def new
          enforce_permission_to :update, :document_section
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_params({})

          render partial: "form"
        end

        private

        def section
          document.sections.find(params[:id])
        end
      end
    end
  end
end
