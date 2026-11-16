# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryDocuments
    module Admin
      describe EvaluationAssignmentForm do
        subject { form }

        let(:organization) { component.participatory_space.organization }
        let(:component) { create(:participatory_documents_component) }
        let(:document) { create(:participatory_documents_document, component:) }
        let(:suggestions) { create_list(:participatory_documents_suggestion, 2, suggestable: document) }
        let(:evaluator_process) { component.participatory_space }
        let(:evaluator) { create(:user, organization:) }
        let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: evaluator_process) }
        let(:params) { { evaluator_role_ids: [evaluator_role.try(:id)], suggestion_ids: suggestions.map(&:id) } }
        let(:form) { described_class.from_params(params).with_context(current_component: component, current_participatory_space: component.participatory_space) }

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "without evaluator roles" do
          let(:evaluator_role) { nil }

          it { is_expected.to be_invalid }
        end

        context "when not enough suggestions" do
          let(:suggestions) { [] }

          it { is_expected.to be_invalid }
        end

        context "when given a evaluator role from another space" do
          let(:evaluator_process) { create(:participatory_process, organization:) }

          it { is_expected.to be_invalid }
        end

        context "when the suggestions belong to another component" do
          let(:other_document) { create(:participatory_documents_document) }
          let(:suggestions) { create_list(:participatory_documents_suggestion, 2, suggestable: other_document) }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
