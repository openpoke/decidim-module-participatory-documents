# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe AnswerSuggestion do
        subject { described_class.new(form, suggestion) }

        let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let(:document) { create(:participatory_documents_document) }

        let(:invalid) { false }
        let(:state) { "not_answered" }
        let(:answer_is_published) { false }
        let(:answer) { { en: "Some text for answer" } }
        let(:form) do
          double(
            current_organization: document.component.organization,
            current_user: document.author,
            invalid?: invalid,
            state:,
            answer:,
            answer_is_published:
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        shared_examples "provides an answer to suggestion" do |selection:, draft: false|
          let(:state) { selection }
          let(:answer_is_published) { draft }

          it "provides an answer" do
            expect(suggestion.answer).to eq({})
            subject.call
            suggestion.reload
            expect(suggestion.answer["en"]).to eq("Some text for answer")
            expect(suggestion.state).to eq(selection)
            expect(suggestion.answer_is_published).to eq(answer_is_published)
          end

          it "saves an additional version", :versioning do
            expect(suggestion.versions.count).to eq(1)
            subject.call
            suggestion.reload
            expect(suggestion.versions.count).to eq(2)
          end
        end

        shared_examples "published an answer for suggestion" do |selection:|
          it_behaves_like "provides an answer to suggestion", selection:, draft: false
        end

        shared_examples "saves a draft answer for suggestion" do |selection:|
          it_behaves_like "provides an answer to suggestion", selection:, draft: true

          it "does not publishes an event" do
            expect { subject.call }.not_to have_enqueued_job
          end
        end

        context "when the suggestion is not_answered" do
          it_behaves_like "published an answer for suggestion", selection: "not_answered"
          it_behaves_like "saves a draft answer for suggestion", selection: "not_answered"
        end

        context "when the suggestion is accepted" do
          it_behaves_like "published an answer for suggestion", selection: "accepted"
          it_behaves_like "saves a draft answer for suggestion", selection: "accepted"
        end

        context "when the suggestion is rejected" do
          it_behaves_like "published an answer for suggestion", selection: "rejected"
          it_behaves_like "saves a draft answer for suggestion", selection: "rejected"
        end

        context "when the suggestion is evaluating" do
          it_behaves_like "published an answer for suggestion", selection: "evaluating"
          it_behaves_like "saves a draft answer for suggestion", selection: "evaluating"
        end
      end
    end
  end
end
