# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationsController < Admin::ApplicationController
        layout false

        rescue_from ActiveRecord::RecordNotFound do |_exception|
          render json: { error: I18n.t("decidim.errors.not_found.content_doesnt_exist") }, status: :not_found
        end

        def destroy
          enforce_permission_to :create, :document_annotations
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

        def update
          enforce_permission_to :update, :document_annotations
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnnotationForm).from_params(params)

          Admin::UpdateAnnotation.call(@form, document) do
            on(:ok) do |annotation|
              render(json: { data: annotation.serialize }, status: :accepted) && return
            end

            on(:invalid) do
              render(json: @form.errors, status: :bad_request) && return
            end
          end
        end

        def create
          enforce_permission_to :create, :document_annotations
          @form = form(Decidim::ParticipatoryDocuments::Admin::AnnotationForm).from_params(params)

          Admin::CreateAnnotation.call(@form, document) do
            on(:ok) do |annotation|
              render(json: { data: annotation.serialize }, status: :created) && return
            end

            on(:invalid) do
              render(json: @form.errors, status: :bad_request) && return
            end
          end
        end
      end
    end
  end
end
