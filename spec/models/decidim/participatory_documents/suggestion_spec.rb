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

        it { is_expected.not_to be_valid }
      end

      describe "sorting in the admin suggestions table" do
        %w(id translated_body author suggestable published state evaluation_assignments_count created_at).each do |column|
          it "applies an order when sorting by #{column}" do
            expect(described_class.ransack(s: "#{column} desc").result.order_values).not_to be_empty
          end
        end

        context "when sorting by creation date" do
          let!(:older) { create(:participatory_documents_suggestion, created_at: 2.days.ago) }
          let!(:newer) { create(:participatory_documents_suggestion, created_at: 1.day.ago) }
          let(:scope) { described_class.where(id: [older.id, newer.id]) }

          it "orders the suggestions in both directions" do
            expect(scope.ransack(s: "created_at asc").result.ids).to eq([older.id, newer.id])
            expect(scope.ransack(s: "created_at desc").result.ids).to eq([newer.id, older.id])
          end
        end
      end
    end
  end
end
