# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe DocumentsController do
        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { document.component }
        let(:document) { create(:participatory_documents_document, :with_file) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "GET pdf_viewer" do
          it_behaves_like "a pdf viewer allowing the storage host"
        end

        describe "GET index" do
          render_views

          context "when the component has no document and the user is an evaluator" do
            let(:component) { create(:participatory_documents_component) }
            let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
            let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process:) }

            it "renders the page" do
              get :index

              expect(response).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end
end
