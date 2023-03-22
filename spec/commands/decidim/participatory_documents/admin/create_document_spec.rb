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
        let(:errors) { double.as_null_object }
        let(:form) do
          double(
            invalid?: invalid,
            title: title,
            description: description,
            box_color: box_color,
            box_opacity: box_opacity,
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
          let(:document) { Decidim::ParticipatoryDocuments::Document.last }

          it "creates a document" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::Document, :count).by(1)
            expect { subject.call }.to broadcast(:ok)
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
