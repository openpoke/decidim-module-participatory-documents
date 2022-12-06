# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class ZonesController < Admin::ApplicationController
        layout false, only: [:new, :edit]
        helper_method :document

        def create
          enforce_permission_to :update, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::ZoneForm).from_params(params)

          Admin::CreateZone.call(@form, document) do
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
          @form = form(Decidim::ParticipatoryDocuments::Admin::ZoneForm).from_params(params)

          Admin::UpdateZone.call(@form, document) do
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
          @form = form(Decidim::ParticipatoryDocuments::Admin::ZoneForm).from_model(zone)

          render partial: "form"
        end

        def new
          enforce_permission_to :update, :participatory_document
          @form = form(Decidim::ParticipatoryDocuments::Admin::ZoneForm).from_params({})

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
