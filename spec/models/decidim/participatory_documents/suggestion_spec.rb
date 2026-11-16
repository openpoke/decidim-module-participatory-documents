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

      describe ".with_evaluation_assigned_to" do
        let(:component) { create(:participatory_documents_component) }
        let(:space) { component.participatory_space }
        let(:document) { create(:participatory_documents_document, component:) }
        let(:evaluator) { create(:user, :confirmed, organization: component.organization) }
        let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: space) }
        let!(:assigned_suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let!(:other_suggestion) { create(:participatory_documents_suggestion, suggestable: document) }

        before { create(:suggestion_evaluation_assignment, suggestion: assigned_suggestion, evaluator_role:) }

        it "returns only the suggestions assigned to the user" do
          expect(described_class.with_evaluation_assigned_to(evaluator, space)).to contain_exactly(assigned_suggestion)
        end

        it "returns nothing for a user without assignments" do
          expect(described_class.with_evaluation_assigned_to(create(:user, organization: component.organization), space)).to be_empty
        end
      end

      describe "#can_participate?" do
        let(:user) { create(:user, :confirmed, organization: suggestion.organization) }

        it "allows the participants of a published component" do
          expect(suggestion.can_participate?(user)).to be(true)
        end

        context "when the component is not published" do
          before { suggestion.component.update!(published_at: nil) }

          it "does not allow the participants" do
            expect(suggestion.can_participate?(user)).to be(false)
          end
        end
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
