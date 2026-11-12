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
        let(:connect_src) { response.headers["Content-Security-Policy"][/connect-src [^;]*/] }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "GET pdf_viewer" do
          context "when the file is stored in a remote service" do
            before do
              allow(ActiveStorage::Blob.service).to receive(:url).and_return("https://storage.example.org/bucket/file.pdf?X-Amz-Signature=abc")
            end

            it "allows the storage host in the connect-src directive" do
              get :pdf_viewer

              expect(connect_src.split).to include("https://storage.example.org")
            end
          end

          context "when the file is stored in the local service" do
            it "does not add the application host to the connect-src directive" do
              get :pdf_viewer

              expect(connect_src).not_to include("test.host")
            end
          end
        end
      end
    end
  end
end
