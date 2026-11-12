# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe AssignSuggestionsToEvaluator do
        describe "call" do
          let(:component) { create(:participatory_documents_component) }
          let(:organization) { component.organization }
          let(:document) { create(:participatory_documents_document, component:) }
          let(:section) { create(:participatory_documents_section, document:) }
          let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section) }
          let(:user) { create(:user, :admin, :confirmed, organization:) }
          let(:evaluator) { create(:user, organization:) }
          let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: component.participatory_space) }
          let(:form) { instance_double(EvaluationAssignmentForm, current_user: user, evaluator_roles: [evaluator_role], suggestions: [suggestion], valid?: valid) }
          let(:command) { described_class.new(form) }

          describe "when the form is not valid" do
            let(:valid) { false }

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "does not create the assignments" do
              expect { command.call }.not_to change(EvaluationAssignment, :count)
            end
          end

          describe "when the form is valid" do
            let(:valid) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the evaluation assignment between the evaluator and the suggestion" do
              expect { command.call }.to change { EvaluationAssignment.where(suggestion:, evaluator_role:).count }.by(1)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:create!)
                .with(Decidim::ParticipatoryDocuments::EvaluationAssignment, user, suggestion:, evaluator_role:)
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
              expect(action_log.version.event).to eq "create"
            end

            context "when the suggestion is already assigned to the evaluator" do
              before do
                create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:)
              end

              it "broadcasts ok" do
                expect { command.call }.to broadcast(:ok)
              end

              it "does not create another assignment" do
                expect { command.call }.not_to change(EvaluationAssignment, :count)
              end
            end

            context "when it raises an error while creating assignments" do
              before do
                allow(Decidim::ParticipatoryDocuments::EvaluationAssignment).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
              end

              it "broadcasts invalid" do
                expect { command.call }.to broadcast(:invalid)
              end

              it "does not create any assignment" do
                expect { command.call }.not_to change(EvaluationAssignment, :count)
              end
            end
          end
        end
      end
    end
  end
end
