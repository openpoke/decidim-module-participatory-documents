# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe SectionsController, type: :controller do
        routes { Decidim::ParticipatoryDocuments::AdminEngine.routes }

        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { document.component }
        let(:document) { create(:participatory_documents_document) }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:model) { Decidim::ParticipatoryDocuments::Section }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe ".update" do
          let!(:section) { create(:participatory_documents_section, document: document, title: nil) }

          let(:params) do
            {
              "document_id": document.id,
              "id": section.id,
              "title_en" => "Title"
            }
          end

          it "Changes the database record" do
            expect(section.title["en"]).to eq("Section 1")
            post(:update, params: params)
            section.reload
            expect(section.title["en"]).to eq("Title")
          end
        end
      end
    end
  end
end
