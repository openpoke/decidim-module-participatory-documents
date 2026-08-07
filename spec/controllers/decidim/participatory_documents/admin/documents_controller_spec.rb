# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe DocumentsController do
        routes { Decidim::ParticipatoryDocuments::AdminEngine.routes }

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
        end

        describe "GET edit_pdf" do
          context "when the file is stored in a remote service" do
            let(:remote_url) { "https://eu2.contabostorage.com/bucket/file.pdf?X-Amz-Signature=abc" }

            before do
              allow(ActiveStorage::Blob.service).to receive(:url).and_return(remote_url)
            end

            it "appends the storage host to the connect-src CSP directive" do
              get :edit_pdf
              expect(response.headers["Content-Security-Policy"]).to match(%r{connect-src [^;]*https://eu2\.contabostorage\.com})
            end
          end
        end
      end
    end
  end
end
