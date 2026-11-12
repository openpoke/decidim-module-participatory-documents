# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe DocumentsController do
      let(:organization) { component.organization }
      let(:participatory_process) { component.participatory_space }
      let(:component) { document.component }
      let(:document) { create(:participatory_documents_document, :with_file) }
      let(:connect_src) { response.headers["Content-Security-Policy"][/connect-src [^;]*/] }

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

        context "when the file is stored in a remote service" do
          before do
            allow(ActiveStorage::Blob.service).to receive(:url).and_return("https://storage.example.org/bucket/file.pdf?X-Amz-Signature=abc")
          end

          it "allows the storage host in the connect-src directive" do
            get :pdf_viewer

            expect(connect_src.split).to include("https://storage.example.org")
          end
        end

        context "when the remote service uses a custom port" do
          before do
            allow(ActiveStorage::Blob.service).to receive(:url).and_return("http://storage.example.org:9000/bucket/file.pdf")
          end

          it "keeps the port in the connect-src directive" do
            get :pdf_viewer

            expect(connect_src.split).to include("http://storage.example.org:9000")
          end
        end

        context "when the file is stored in the local service" do
          it "does not add the application host to the connect-src directive" do
            get :pdf_viewer

            expect(connect_src).to include("'self'")
            expect(connect_src).not_to include("test.host")
          end
        end

        context "when the document has no file attached" do
          let(:document) { create(:participatory_documents_document) }

          it "does not change the connect-src directive" do
            get :pdf_viewer

            expect(connect_src).not_to include("test.host")
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
