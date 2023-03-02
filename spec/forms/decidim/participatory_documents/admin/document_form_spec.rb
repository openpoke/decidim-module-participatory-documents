# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe DocumentForm do
        subject { document }

        let(:title) { "Test title" }
        let(:description) { "Test description" }
        let(:box_color) { "#f00f00" }
        let(:box_opacity) { 50 }
        let(:document) { create(:participatory_documents_document, title: { en: title }, description: { en: description }, box_color: box_color, box_opacity: box_opacity) }

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

          it "is invalid" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end
end
