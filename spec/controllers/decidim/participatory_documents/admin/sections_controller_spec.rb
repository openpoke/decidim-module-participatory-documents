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

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "destroy a section" do
          let!(:section) { create(:participatory_documents_section, document: document, uid: "randomstring") }

          it "removes the entry from db" do
            expect(Decidim::ParticipatoryDocuments::Section.count).to eq(1)
            expect do
              delete(:destroy, params: { document_id: document.id, id: section.uid })
            end.to change(Decidim::ParticipatoryDocuments::Section, :count).by(-1)
          end
        end
      end
    end
  end
end
