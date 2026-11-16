# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe PublishAnswers do
        subject { command.call }

        let(:command) { described_class.new(component, user, suggestion_ids) }
        let(:document) { create(:participatory_documents_document) }
        let(:component) { document.component }
        let(:user) { document.author }
        let(:suggestion_ids) { suggestions.map(&:id) }
        let(:suggestions) { [:accepted, :evaluating, :rejected].map { |state| create(:participatory_documents_suggestion, state, :draft, :with_answer, suggestable: document) } }

        it "broadcasts ok" do
          expect { subject }.to broadcast(:ok)
        end

        it "publishes the answers" do
          expect { subject }.to change { suggestions.map { |suggestion| suggestion.reload.answer_is_published }.uniq }.from([false]).to([true])
        end

        it "traces the action", versioning: true do
          suggestions.each do |suggestion|
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("publish_answer", suggestion, user)
              .and_call_original
          end

          expect { subject }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end

        it "notifies the answers" do
          suggestions.each do |suggestion|
            expect(NotifySuggestionAnswer)
              .to receive(:call)
              .with(suggestion)
          end

          subject
        end

        context "when the answers are already published" do
          let(:suggestions) { [:accepted, :evaluating, :rejected].map { |state| create(:participatory_documents_suggestion, state, :published, :with_answer, suggestable: document) } }

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end

          it "does not trace the action" do
            expect(Decidim.traceability)
              .not_to receive(:perform_action!)

            subject
          end

          it "does not notify the answers" do
            expect(NotifySuggestionAnswer).not_to receive(:call)

            subject
          end
        end

        context "when the suggestions do not have answers" do
          let(:suggestions) { [:accepted, :evaluating, :rejected].map { |state| create(:participatory_documents_suggestion, state, :draft, suggestable: document) } }

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end

          it "does not publish the answers" do
            expect { subject }.not_to(change { suggestions.map { |suggestion| suggestion.reload.answer_is_published }.uniq })
          end

          it "does not notify the answers" do
            expect(NotifySuggestionAnswer).not_to receive(:call)

            subject
          end
        end

        context "when only some of the suggestions have answers" do
          let(:answered) { create(:participatory_documents_suggestion, :accepted, :draft, :with_answer, suggestable: document) }
          let(:not_answered) { create(:participatory_documents_suggestion, :not_answered, :draft, suggestable: document) }
          let(:suggestions) { [answered, not_answered] }

          it "publishes only the answered ones" do
            subject

            expect(answered.reload.answer_is_published).to be true
            expect(not_answered.reload.answer_is_published).to be false
          end
        end

        context "when suggestion ids belong to other component" do
          let(:other_document) { create(:participatory_documents_document) }
          let(:suggestions) { create_list(:participatory_documents_suggestion, 3, :accepted, :draft, :with_answer, suggestable: other_document) }

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end

          it "does not publish the answers" do
            expect { subject }.not_to(change { suggestions.map { |suggestion| suggestion.reload.answer_is_published }.uniq })
          end

          it "does not trace the action" do
            expect(Decidim.traceability)
              .not_to receive(:perform_action!)

            subject
          end

          it "does not notify the answers" do
            expect(NotifySuggestionAnswer).not_to receive(:call)

            subject
          end
        end
      end
    end
  end
end
