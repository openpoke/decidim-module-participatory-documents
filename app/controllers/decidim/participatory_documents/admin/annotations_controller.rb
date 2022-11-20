# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationsController < Admin::ApplicationController
        layout false
        def destroy
          enforce_permission_to :create, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnnotationForm).from_params(params)

          Admin::DestroyAnnotation.call(@form, document) do
            on(:ok) do
              render(json: {}, status: :accepted) && return
            end

            on(:invalid) do
              render(json: {}, status: :bad_request) && return
            end
          end
        end

        def create
          enforce_permission_to :create, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnnotationForm).from_params(params)

          Admin::CreateAnnotation.call(@form, document) do
            on(:ok) do |annotation|
              render(json: { id: annotation.id }, status: :created) && return
            end

            on(:invalid) do
              render(json: {}, status: :bad_request) && return
            end
          end
        end

        private

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by!(component: current_component)
        end
      end
    end
  end
end
