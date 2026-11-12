# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe AnnotationsController do
        let(:organization) { component.organization }
        let(:participatory_process) { component.participatory_space }
        let(:component) { document.component }
        let(:document) { create(:participatory_documents_document) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:model) { Decidim::ParticipatoryDocuments::Annotation }
        let(:sections) { Decidim::ParticipatoryDocuments::Section }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_space"] = participatory_process
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "POST create" do
          let(:params) { { document_id: document.id, page_number: 1, rect: { left: 50, top: 50, width: 100, height: 100 } } }

          it "creates a new annotation and section" do
            expect { post(:create, params:) }.to change(model, :count).by(1).and change(sections, :count).by(1)
          end

          context "when the document is published" do
            let(:document) { create(:participatory_documents_document, published_at: Time.current) }

            it "does not create the annotation" do
              expect { post(:create, params:) }.not_to change(model, :count)
            end
          end
        end

        describe "DELETE destroy" do
          let!(:annotation) { create(:participatory_documents_annotation) }
          let!(:section) { create(:participatory_documents_section, document:, annotations: [annotation]) }

          let(:params) { { document_id: document.id, id: annotation.id } }

          it "deletes the annotation and section" do
            expect { delete(:destroy, params:) }.to change(model, :count).by(-1).and change(sections, :count).by(-1)
          end
        end
      end
    end
  end
end
