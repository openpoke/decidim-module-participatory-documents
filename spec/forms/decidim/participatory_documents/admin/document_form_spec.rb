# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments::Admin
  describe DocumentForm do
    subject { described_class.from_model(document) }

    let(:title) { "Test title" }
    let(:description) { "Test description" }
    let(:box_color) { "#f00f00" }
    let(:box_opacity) { 50 }
    let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
    let(:document) { create(:participatory_documents_document, title: { en: title }, description: { en: description }, file:, box_color:, box_opacity:) }

    context "when the document has a title and a description" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when the document has no title or description" do
      let(:title) { nil }
      let(:description) { nil }
      let(:box_color) { nil }
      let(:box_opacity) { nil }

      it "is valid" do
        expect(subject).to be_valid
        expect(subject.box_color).to eq("#1e98d7")
        expect(subject.box_opacity).to eq(12)
      end
    end

    context "when from params" do
      subject { described_class.from_params(params).with_context(current_organization: organization) }
      let(:organization) { create(:organization) }

      let(:params) do
        {
          title: { en: title },
          file:,
          description: { en: description },
          box_color:,
          box_opacity:
        }
      end

      it "is valid" do
        expect(subject).to be_valid
      end

      context "when the document has no title or description" do
        let(:title) { nil }
        let(:description) { nil }
        let(:box_color) { nil }
        let(:box_opacity) { nil }

        it "is has no color or opacity" do
          expect(subject).to be_valid
          expect(subject.box_color).to be_nil
          expect(subject.box_opacity).to be_nil
        end
      end

      context "when the document has no file" do
        let(:file) { nil }

        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "when the document has a file with an invalid extension" do
        let(:file) { upload_test_file(Decidim::Dev.test_file("dummy-dummies-example.json", "application/pdf")) }

        it "is valid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
