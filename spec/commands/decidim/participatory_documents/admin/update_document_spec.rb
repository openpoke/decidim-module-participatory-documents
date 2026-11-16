# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe UpdateDocument do
        subject { described_class.new(form, document) }

        let(:document) { create(:participatory_documents_document) }
        let(:component) { document.component }
        let(:current_user) { document.author }
        let(:title) { { en: "Title test Section" } }
        let(:description) { { en: "Description test Section" } }
        let(:box_color) { "#f00f00" }
        let(:box_opacity) { 50 }
        let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
        let(:params) { { title:, description:, box_color:, box_opacity:, file: } }
        let(:form) { DocumentForm.from_params(params).with_context(current_organization: component.organization, current_component: component, current_user:) }

        context "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when is not the right file" do
          let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "adds an error to the form" do
            subject.call

            expect(form.errors[:file]).to include("only files with the following extensions are allowed: pdf")
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

        context "when the document has sections and the file is not changed" do
          let(:document) { create(:participatory_documents_document, :with_file, :with_sections) }
          let(:file) { document.file.blob }

          it "keeps the sections" do
            expect { subject.call }.not_to(change { document.sections.count })
            expect(document.reload.title["en"]).to eq(title[:en])
          end
        end

        context "when the file is rejected by the document" do
          let(:file) { Decidim::Dev.test_file("dummy-dummies-example.json", "application/json") }

          before do
            allow(form).to receive(:invalid?).and_return(false)
          end

          it "broadcasts :invalid and adds an error to the form" do
            expect { subject.call }.to broadcast(:invalid)
            expect(form.errors[:file].flatten).to include("only files with the following extensions are allowed: pdf")
            document.reload
            expect(document.file.attached?).to be false
          end
        end
      end
    end
  end
end
