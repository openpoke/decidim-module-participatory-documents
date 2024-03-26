# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SectionsController < Admin::ApplicationController
        layout false, only: [:new, :edit]

        def edit
          enforce_permission_to :update, :document_section
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_model(section)

          render partial: "form"
        end

        def update
          enforce_permission_to :update, :document_section
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_params(params)
byebug
          Admin::UpdateSection.call(@form, document) do
            on(:ok) do |_annotation|
              render(json: {}, status: :accepted) && return
            end

            on(:invalid) do
              render(partial: "form", status: :bad_request) && return
            end
          end
        end

        private

        def section
          document.sections.find(params[:id])
        end
      end
    end
  end
end
