# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe SuggestionForm do
      subject { form }

      let(:component) { create :participatory_documents_component }
      let(:document) { create(:participatory_documents_document, component: component) }

      let(:form) do
        described_class.from_params(
          {
            body: "This is a suggestion body",
            file: example_file
          }
        )
      end

      let(:example_file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

      it "is valid with valid attributes" do
        expect(form).to be_valid
      end

      it "is invalid without a body and file" do
        form.body = nil
        form.file = nil

        expect(form).to be_invalid
        expect(form.errors[:base]).to include(I18n.t("activemodel.errors.models.suggestion.attributes.not_blank"))
      end

      it "is invalid with a body that is too short" do
        form.body = "body"

        expect(form).to be_invalid
        expect(form.errors[:body]).to include(I18n.t("activemodel.errors.models.suggestion.attributes.too_short", min_length: Decidim::ParticipatoryDocuments.config.min_suggestion_length))
      end

      it "is invalid with a body that is too long" do
        form.body = "Long body" * 300

        expect(form).to be_invalid
        expect(form.errors[:body]).to include(I18n.t("activemodel.errors.models.suggestion.attributes.too_long", max_length: Decidim::ParticipatoryDocuments.config.max_suggestion_length))
      end
    end
  end
end
