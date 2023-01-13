# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe CreateDocument do
        subject { described_class.new(form) }

        let(:title) { { en: "Title test Section" } }
        let(:description) { { en: "Description test Section" } }
        let(:invalid) { false }
        let(:component) { create(:participatory_documents_component) }
        let(:current_user) { create(:user, :admin, :confirmed, organization: component.organization) }
        let(:errors) { double.as_null_object }
        let(:form) do
          double(
            invalid?: invalid,
            title: title,
            description: description,
            current_user: current_user,
            file: file,
            current_component: component,
            errors: errors
          )
        end
        let(:file) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"),
            "application/pdf"
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          context "when is not the right file" do
            let(:file) do
              Rack::Test::UploadedFile.new(
                Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
                "image/jpeg"
              )
            end

            it "is not valid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end
        end

        context "when everything is ok" do
          it "creates a section" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Document, :count).by(1)
          end
        end
      end
    end
  end
end
