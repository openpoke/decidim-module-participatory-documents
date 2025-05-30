# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe UpdateDocument do
        subject { described_class.new(form, document) }

        let(:document) { create(:participatory_documents_document) }

        let(:title) { { en: "Title test Section" } }
        let(:description) { { en: "Description test Section" } }
        let(:box_color) { "#f00f00" }
        let(:box_opacity) { 50 }
        let(:component) { document.component }
        let(:current_user) { document.author }
        let(:invalid) { false }
        let(:errors) { double.as_null_object }

        let(:form) do
          double(
            invalid?: invalid,
            title:,
            description:,
            box_color:,
            box_opacity:,
            current_user:,
            file:,
            current_component: component,
            errors:
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
          it "creates the attributes" do
            expect(document.title["en"]).not_to eq(title[:en])
            subject.call
            document.reload
            expect(document.title["en"]).to eq(title[:en])
            expect(document.description["en"]).to eq(description[:en])
            expect(document.box_color).to eq(box_color)
            expect(document.box_opacity).to eq(box_opacity)
          end
        end

        context "when the file is invalid" do
          let(:file) do
            Rack::Test::UploadedFile.new(
              Decidim::Dev.test_file("dummy-dummies-example.json", "application/pdf")
            )
          end

          it "broadcasts :invalid and adds an error to the form" do
            expect { subject.call }.to broadcast(:invalid)
            expect(form.errors[:file]).to include("is invalid")
            document.reload
            expect(document.file.attached?).to be false
          end
        end
      end
    end
  end
end
