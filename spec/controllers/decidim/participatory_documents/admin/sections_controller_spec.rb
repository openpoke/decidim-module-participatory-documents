# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe SectionsController do
        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { document.component }
        let(:document) { create(:participatory_documents_document) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "PATCH update" do
          let!(:section) { create(:participatory_documents_section, document:, title: nil) }
          let(:params) { { document_id: document.id, id: section.id, title_en: "Title" } }

          it "updates the section title" do
            expect(section.title["en"]).to eq("Section 0")
            patch(:update, params:)
            section.reload
            expect(section.title["en"]).to eq("Title")
          end
        end
      end
    end
  end
end
