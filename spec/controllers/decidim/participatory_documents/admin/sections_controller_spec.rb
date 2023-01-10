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

        describe ".destroy" do
          let!(:section) { create(:participatory_documents_section, document: document, uid: "randomstring") }

          let(:params) { { document_id: document.id, id: section.uid } }
          it "removes the entry from database" do
            expect(model.count).to eq(1)
            expect { delete(:destroy, params: params) }.to change( model, :count).by(-1)
            expect(model.count).to eq(0)
          end
        end

        describe ".create" do
          let(:params) { {
            "uid": "randomstring",
            "document_id": document.id,
            "title_en" => "Title",
            "description_en" => "description",
            "page_number" => "1",
            "rect" => [ 5, 100, 50, 100]
          } }
          it "Adds a new entry to database" do
            expect(model.count).to eq(0)
            expect { post :create, params: params}.to change(model, :count).by(1)
          end
        end

        describe ".update" do
          let!(:section) { create(:participatory_documents_section, document: document, uid: "randomstring") }

          let(:params) { {
            "document_id": document.id,
            "id": section.uid,
            "uid": section.uid,
            "title_en" => "Title",
            "description_en" => "description",
            "page_number" => "1",
            "rect" => [ 5, 100, 50, 100]
          } }

          it "Changes the database record" do
            expect(section.title).to be_nil
            expect(section.description).to be_nil
            post(:update, params: params)
            section.reload
            expect(section.title["en"]).to eq("Title")
            expect(section.description["en"]).to eq("description")
          end
        end

      end
    end
  end
end
