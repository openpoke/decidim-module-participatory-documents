# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe UnassignSuggestionsFromEvaluator do
        describe "call" do
          let(:component) { create(:participatory_documents_component) }
          let(:organization) { component.organization }
          let(:document) { create(:participatory_documents_document, component:) }
          let(:section) { create(:participatory_documents_section, document:) }
          let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section) }
          let(:user) { create(:user, :admin, :confirmed, organization:) }
          let(:evaluator) { create(:user, organization:) }
          let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: component.participatory_space) }
          let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }
          let(:form) { instance_double(EvaluationAssignmentForm, current_user: user, evaluator_roles: [evaluator_role], suggestions: [suggestion], valid?: valid) }
          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not destroy the assignments" do
              expect { command.call }.not_to change(EvaluationAssignment, :count)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "destroys the evaluation assignment between the evaluator and the suggestion" do
              expect { command.call }.to change { EvaluationAssignment.where(suggestion:, evaluator_role:).count }.from(1).to(0)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:perform_action!)
                .with(:delete, assignment, user, suggestion_title: suggestion.body)
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
              expect(action_log.version.event).to eq "destroy"
            end

            it "stores the suggestion body in the action log" do
              expect { command.call }.to change(Decidim::ActionLog, :count).by(1)

              action_log = Decidim::ActionLog.last
              expect(action_log.action).to eq("delete")
              expect(action_log.extra["suggestion_title"]).to eq(suggestion.body)
            end

            context "when the suggestion is not assigned" do
              let!(:assignment) { nil }

              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok)
              end

              it "does not destroy any assignment" do
                expect { command.call }.not_to change(EvaluationAssignment, :count)
              end
            end
          end
        end
      end
    end
  end
end
