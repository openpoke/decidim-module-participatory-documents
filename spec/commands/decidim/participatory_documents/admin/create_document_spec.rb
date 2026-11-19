# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe CreateDocument do
        subject { described_class.new(form) }

        let(:title) { { en: "Title test Section" } }
        let(:description) { { en: "Description test Section" } }
        let(:box_color) { "#f00f00" }
        let(:box_opacity) { 50 }
        let(:invalid) { false }
        let(:component) { create(:participatory_documents_component) }
        let(:current_user) { create(:user, :admin, :confirmed, organization: component.organization) }
        let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
        let(:form) { double(invalid?: invalid, title:, description:, box_color:, box_opacity:, current_user:, file:, current_component: component) }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          context "when component is missing" do
            let(:component) { nil }
            let(:current_user) { create(:user, :admin, :confirmed) }

            it "is not valid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end

          context "when current_user is missing" do
            let(:current_user) { nil }

            it "is not valid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end

          context "when is not the right file" do
            let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

            it "is not valid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end
        end

        context "when the file is larger than the maximum size" do
          let(:organization) { component.organization }
          let(:file) { upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")) }
          let(:form) { DocumentForm.from_params(title:, description:, file:).with_context(current_organization: organization, current_component: component, current_user:) }

          before do
            organization.update!(file_upload_settings: Decidim::OrganizationSettings.default(:upload).deep_merge("maximum_file_size" => { "default" => 0.00001 }))
            Decidim::OrganizationSettings.reload(organization)
          end

          it "broadcasts invalid with an error on the file" do
            expect { subject.call }.to broadcast(:invalid)
            expect(form.errors[:file]).to be_present
          end

          it "does not create a document" do
            expect { subject.call }.not_to change(Decidim::ParticipatoryDocuments::Document, :count)
          end
        end

        context "when everything is ok" do
          let(:document) { Decidim::ParticipatoryDocuments::Document.last }

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "creates a document" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Document, :count).by(1)
          end

          it "creates the attributes" do
            subject.call
            document.reload
            expect(document.title["en"]).to eq(title[:en])
            expect(document.description["en"]).to eq(description[:en])
            expect(document.box_color).to eq(box_color)
            expect(document.box_opacity).to eq(box_opacity)
          end
        end
      end
    end
  end
end
