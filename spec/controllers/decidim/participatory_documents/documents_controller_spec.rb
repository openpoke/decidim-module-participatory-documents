# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe DocumentsController do
      routes { Decidim::ParticipatoryDocuments::Engine.routes }

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

        context "when the file is stored in a remote service" do
          let(:remote_url) { "https://eu2.contabostorage.com/bucket/file.pdf?X-Amz-Signature=abc" }

          before do
            allow(ActiveStorage::Blob.service).to receive(:url).and_return(remote_url)
          end

          it "appends the storage host to the connect-src CSP directive" do
            get :pdf_viewer
            expect(response.headers["Content-Security-Policy"]).to match(%r{connect-src [^;]*https://eu2\.contabostorage\.com})
          end
        end

        context "when the file is stored in the local service" do
          it "does not append the request host to the connect-src CSP directive" do
            get :pdf_viewer
            csp = response.headers["Content-Security-Policy"]
            expect(csp).to match(/connect-src [^;]*'self'/)
            expect(csp[/connect-src [^;]*/]).not_to include("test.host")
          end
        end

        context "when the document has no file attached" do
          let(:document) { create(:participatory_documents_document) }

          it "renders without altering the connect-src CSP directive" do
            get :pdf_viewer
            expect(response.headers["Content-Security-Policy"][/connect-src [^;]*/]).not_to include("test.host")
          end
        end
      end
    end
  end
end
