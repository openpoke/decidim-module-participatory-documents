# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class ZonesController < Admin::ApplicationController
        layout false, only: [:new, :edit]
        helper_method :document

        def destroy
          enforce_permission_to :destroy, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_model(zone)

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
          enforce_permission_to :update, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_params(params)

          Admin::CreateSection.call(@form, document) do
            on(:ok) do |_zone|
              render(json: {}, status: :created) && return
            end

            on(:invalid) do
              render(partial: "form", status: :bad_request) && return
            end
          end
        end

        def update
          enforce_permission_to :update, :participatory_document
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
          enforce_permission_to :update, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_model(zone)

          render partial: "form"
        end

        def new
          enforce_permission_to :update, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::SectionForm).from_params({})

          render partial: "form"
        end

        private

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by!(component: current_component)
        end

        def zone
          document.zones.find_by!(uid: params[:id])
        end
      end
    end
  end
end
