# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe SectionSuggestionsController do
      include Decidim::Core::Engine.routes.url_helpers

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:participatory_documents_component, participatory_space: participatory_process) }
      let(:document) { create(:participatory_documents_document, :with_sections, component:) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:model) { Decidim::ParticipatoryDocuments::Suggestion }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = participatory_process
        request.env["decidim.current_component"] = component
        sign_in user if user
      end

      describe "GET index" do
        it "renders the index template" do
          get :index, params: { document_id: document.id, section_id: document.sections.first.id }
          expect(response).to render_template("index")
        end

        context "when non logged" do
          let(:user) { nil }

          it "redirects to the login page" do
            get :index, params: { document_id: document.id, section_id: document.sections.first.id }
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end

      describe "POST create" do
        let(:params) { { document_id: document.id, section_id: document.sections.first.id, body: "A nice suggestion" } }

        it "creates a new suggestion" do
          expect { post(:create, params:) }.to change(model, :count).by(1)
        end

        context "when non logged" do
          let(:user) { nil }

          it "redirects to the login page" do
            post(:create, params:)
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end
    end
  end
end
