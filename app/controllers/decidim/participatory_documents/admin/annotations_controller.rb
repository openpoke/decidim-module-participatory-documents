# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationsController < Admin::ApplicationController
        layout false

        rescue_from ActiveRecord::RecordNotFound do |_exception|
          render json: { error: I18n.t("decidim.errors.not_found.content_doesnt_exist") }, status: :not_found
        end

        def create
          enforce_permission_to :create, :document_annotations
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnnotationForm).from_params(params)

          Admin::UpdateOrCreateAnnotation.call(@form, document) do
            on(:ok) do |annotation|
              render(json: { data: annotation.serialize }, status: :created) && return
            end

            on(:invalid) do
              render(json: @form.errors, status: :unprocessable_entity) && return
            end
          end
        end

        def destroy
          enforce_permission_to :create, :document_annotations
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnnotationForm).from_model(annotation)

          Admin::DestroyAnnotation.call(@form, document) do
            on(:ok) do
              render(json: {}, status: :accepted) && return
            end

            on(:invalid) do
              render(json: {}, status: :unprocessable_entity) && return
            end
          end
        end

        private

        def annotation
          @annotation ||= document.annotations.find(params[:id])
        end
      end
    end
  end
end
