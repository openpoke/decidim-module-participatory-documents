# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe UnassignSuggestionsFromEvaluator do
        subject { described_class.new(form) }

        let(:valid) { true }
        let(:organization) { component.organization }
        let!(:user) { create(:user, :admin, :confirmed, organization:) }

        let(:component) { create(:participatory_documents_component) }
        let(:document) { create(:participatory_documents_document, component:) }
        let(:section1) { create(:participatory_documents_section, document:) }
        let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }
        let(:evaluator) { create(:user, organization:) }

        let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: component.participatory_space) }

        let(:form) do
          double(
            current_organization: organization,
            current_user: user,
            valid?: valid,
            evaluator_roles: [evaluator_role],
            suggestions: [suggestion]
          )
        end

        context "when the form is valid" do
          let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

          it "removes the assignment" do
            expect { subject.call }.to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count).by(-1)
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "stores the suggestion body in the action log" do
            expect { subject.call }.to change(Decidim::ActionLog, :count).by(1)

            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("delete")
            expect(action_log.extra["suggestion_title"]).to eq(suggestion.body)
          end
        end

        context "when the suggestion is not assigned" do
          it "does not fail" do
            expect { subject.call }.not_to change(Decidim::ParticipatoryDocuments::EvaluationAssignment, :count)
            expect { subject.call }.to broadcast(:ok)
          end
        end

        context "when the form is not valid" do
          let(:valid) { false }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
