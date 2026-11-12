# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::AdminLog::EvaluationAssignmentPresenter, type: :helper do
  subject { described_class.new(action_log, helper).present }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:participatory_documents_component, participatory_space:) }
  let(:document) { create(:participatory_documents_document, component:) }
  let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document, body: { en: "Please widen the bike lane" }) }
  let(:evaluator) { create(:user, organization:) }
  let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: participatory_space) }
  let(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }
  let(:action_log) { create(:action_log, user:, action:, resource: assignment, component:, participatory_space:, extra_data:) }
  let(:extra_data) { {} }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  context "when an evaluator is assigned" do
    let(:action) { "create" }

    it "explains which suggestion was assigned" do
      expect(subject).to include("assigned the")
      expect(subject).to include("Please widen the bike lane")
      expect(subject).to include("suggestion to an evaluator")
    end
  end

  context "when an evaluator is unassigned" do
    let(:action) { "delete" }
    let(:extra_data) { { suggestion_title: suggestion.body } }

    it "explains which suggestion was unassigned" do
      expect(subject).to include("unassigned an evaluator from the")
      expect(subject).to include("Please widen the bike lane")
    end
  end
end
