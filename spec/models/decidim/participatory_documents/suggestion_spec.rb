# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    describe Suggestion do
      subject { suggestion }

      let(:suggestion) { create(:participatory_documents_suggestion) }

      include_examples "authorable" do
        subject { suggestion }
      end

      it { is_expected.to be_valid }

      context "when file has an allowed type" do
        before do
          suggestion.file.attach(io: File.open("spec/fixtures/files/example.pdf"), filename: "example.pdf", content_type: "application/pdf")
        end

        it { is_expected.to be_valid }
      end

      context "when file has a disallowed type" do
        before do
          suggestion.file.attach(io: File.open("spec/fixtures/files/test.com"), filename: "test.com", content_type: "text/plain")
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
