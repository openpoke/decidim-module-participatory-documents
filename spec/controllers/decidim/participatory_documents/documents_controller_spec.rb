# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe DocumentsController do
      let(:organization) { component.organization }
      let(:participatory_process) { component.participatory_space }
      let(:component) { document.component }
      let(:document) { create(:participatory_documents_document, :with_file) }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = participatory_process
        request.env["decidim.current_component"] = component
      end

      describe "GET pdf_viewer" do
        it "renders the pdf_viewer template" do
          get :pdf_viewer

          expect(response).to render_template("pdf_viewer")
        end

        it_behaves_like "a pdf viewer allowing the storage host"

        context "when the stored box color is not a hexadecimal color" do
          let(:document) { create(:participatory_documents_document, :with_file, box_color: "#000;}</style><script>alert(1)</script>") }

          it "falls back to the default color" do
            get :pdf_viewer

            expect(controller.helpers.pdf_custom_style).to include("--box-color: #1E98D7;")
            expect(controller.helpers.pdf_custom_style).not_to include("script")
          end
        end

        context "when the component has no document" do
          let(:component) { create(:participatory_documents_component) }

          it "responds with not found" do
            expect { get :pdf_viewer }.to raise_error(ActionController::RoutingError)
          end
        end
      end
    end
  end
end
