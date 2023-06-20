# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe SuggestionForm do
      subject { form }

      let(:context) { double(current_component: component) }
      let(:component) { create :participatory_documents_component }
      let(:document) { create(:participatory_documents_document, component: component) }

      let(:form) do
        described_class.from_params(
          {
            body: body,
            file: example_file
          }
        ).with_context(
          current_component: component
        )
      end

      let(:body) { "This is a suggestion body" }
      let(:example_file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

      shared_examples "validate error message" do |error_key, params|
        it "shows the correct error message" do
          form.validate
          expect(form.errors[:body]).to include(I18n.t("activemodel.errors.models.suggestion.attributes.#{error_key}", params))
        end
      end

      it "is valid with valid attributes" do
        expect(form).to be_valid
      end

      context "when no body" do
        let(:body) { nil }

        it { is_expected.to be_valid }
      end

      context "when no file" do
        let(:example_file) { nil }

        it { is_expected.to be_valid }
      end

      context "when no body, no file" do
        let(:body) { nil }
        let(:example_file) { nil }

        it { is_expected.to be_invalid }

        it_behaves_like "validate error message", "not_blank", {}
      end

      context "when a body that is too short" do
        let(:body) { "body" }

        it { is_expected.to be_invalid }

        it_behaves_like "validate error message", "too_short", { min_length: 5 }
      end

      context "when a body that is too long" do
        let(:body) { "Long body" * 300 }

        it { is_expected.to be_invalid }

        it_behaves_like "validate error message", "too_long", { max_length: 500 }
      end

      context "when default min size is another" do
        let(:body) { "short" }
        let(:component) { double(:participatory_documents_component, settings: settings) }
        let(:settings) { double(:settings, min_suggestion_length: 7, max_suggestion_length: 100) }

        before do
          allow(Decidim::ParticipatoryDocuments).to receive(:min_suggestion_length).and_return(7)
        end

        it { is_expected.to be_invalid }

        it_behaves_like "validate error message", "too_short", { min_length: 7 }

        context "when body is ok" do
          let(:body) { "enough body" }

          it { is_expected.to be_valid }
        end
      end

      context "when default max size is another" do
        let(:body) { "Long body" * 300 }
        let(:component) { double(:participatory_documents_component, settings: settings) }
        let(:settings) { double(:settings, min_suggestion_length: 5, max_suggestion_length: 200) }

        before do
          allow(Decidim::ParticipatoryDocuments).to receive(:max_suggestion_length).and_return(200)
        end

        it { is_expected.to be_invalid }

        it_behaves_like "validate error message", "too_long", { max_length: 200 }

        context "when body is ok" do
          let(:body) { "enough body" }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
