# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe DocumentSuggestionsController, type: :controller do
      routes { Decidim::ParticipatoryDocuments::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:component) { create(:participatory_documents_component, participatory_space: participatory_process) }
      let(:document) { create(:participatory_documents_document, component: component) }
      let(:user) { create :user, :confirmed, organization: organization }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = participatory_process
        request.env["decidim.current_component"] = component
        sign_in user
      end

        describe ".create" do
          let(:params) do
            {
              "document_id" => document.id,
              "page_number" => 1,
              "rect" => { left: 50, top: 50, width: 100, height: 100 }
            }
          end

          it "Creates a new annotation and section" do
            expect do
              post(:create, params: params)
            end.to change(model, :count).by(1).and change(sections, :count).by(1)
          end
        end


    end
  end
end
