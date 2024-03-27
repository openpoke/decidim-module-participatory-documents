# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe PublishAnswers do
        subject { described_class }

        # document.author
        let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
        let(:document) { create(:participatory_documents_document) }

        let(:suggestion_ids) { [accepted_suggestion.id, evaluating_suggestion.id, accepted_suggestion.id] }

        context "when suggestions are not publihed" do
          let!(:accepted_suggestion) { create(:participatory_documents_suggestion, :accepted, :draft, :with_answer, suggestable: document) }
          let!(:evaluating_suggestion) { create(:participatory_documents_suggestion, :evaluating, :with_answer, suggestable: document) }
          let!(:rejected_suggestion) { create(:participatory_documents_suggestion, :rejected, :with_answer, suggestable: document) }

          it "sends the accepted notifications" do
            expect(NotifySuggestionAnswer).to receive(:call).with(accepted_suggestion, nil)
            expect { subject.call(document.component, document.author, [accepted_suggestion.id]) }.not_to broadcast(:invalid)
          end

          it "sends the rejected notifications" do
            expect(NotifySuggestionAnswer).to receive(:call).with(rejected_suggestion, nil)
            expect { subject.call(document.component, document.author, [rejected_suggestion.id]) }.not_to broadcast(:invalid)
          end

          it "sends the evaluating notifications" do
            expect(NotifySuggestionAnswer).to receive(:call).with(evaluating_suggestion, nil)
            expect { subject.call(document.component, document.author, [evaluating_suggestion.id]) }.not_to broadcast(:invalid)
          end
        end

        context "when suggestions are published" do
          let(:accepted_suggestion) { create(:participatory_documents_suggestion, :accepted, :with_answer, :published, suggestable: document) }
          let(:evaluating_suggestion) { create(:participatory_documents_suggestion, :evaluating, :with_answer, :published, suggestable: document) }
          let(:rejected_suggestion) { create(:participatory_documents_suggestion, :rejected, :with_answer, :published, suggestable: document) }

          it "sends the accepted notifications" do
            expect(NotifySuggestionAnswer).not_to receive(:call).with(accepted_suggestion, nil)
            expect { subject.call(document.component, document.author, [accepted_suggestion.id]) }.not_to broadcast(:invalid)
          end

          it "sends the rejected notifications" do
            expect(NotifySuggestionAnswer).not_to receive(:call).with(rejected_suggestion, nil)
            expect { subject.call(document.component, document.author, [rejected_suggestion.id]) }.not_to broadcast(:invalid)
          end

          it "sends the evaluating notifications" do
            expect(NotifySuggestionAnswer).not_to receive(:call).with(evaluating_suggestion, nil)
            expect { subject.call(document.component, document.author, [evaluating_suggestion.id]) }.not_to broadcast(:invalid)
          end
        end

        context "when suggestions do not have answers" do
          let(:accepted_suggestion) { create(:participatory_documents_suggestion, :accepted, :draft, suggestable: document) }
          let(:evaluating_suggestion) { create(:participatory_documents_suggestion, :evaluating, :draft, suggestable: document) }
          let(:rejected_suggestion) { create(:participatory_documents_suggestion, :rejected, :draft, suggestable: document) }

          it "sends the accepted notifications" do
            expect(NotifySuggestionAnswer).not_to receive(:call).with(accepted_suggestion, nil)
            expect { subject.call(document.component, document.author, [accepted_suggestion.id]) }.not_to broadcast(:invalid)
          end

          it "sends the rejected notifications" do
            expect(NotifySuggestionAnswer).not_to receive(:call).with(rejected_suggestion, nil)
            expect { subject.call(document.component, document.author, [rejected_suggestion.id]) }.not_to broadcast(:invalid)
          end

          it "sends the evaluating notifications" do
            expect(NotifySuggestionAnswer).not_to receive(:call).with(evaluating_suggestion, nil)
            expect { subject.call(document.component, document.author, [evaluating_suggestion.id]) }.not_to broadcast(:invalid)
          end
        end
      end
    end
  end
end
