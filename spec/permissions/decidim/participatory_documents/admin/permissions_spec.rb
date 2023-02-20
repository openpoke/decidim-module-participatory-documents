# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:component) { build :participatory_documents_component }
  let(:organization) { component.participatory_space.organization }
  let(:document) { create(:participatory_documents_document, component: component) }
  let(:user) { create :user, :admin, :confirmed, organization: component.organization }
  let(:permission_action) { Decidim::PermissionAction.new(scope: :admin, action: action_name, subject: action_subject) }
  let(:suggestion) { nil }
  let(:context) do
    {
      current_component: component,
      current_settings: double(suggestion_answering_enabled: true),
      component_settings: double(suggestion_answering_enabled: true),
      suggestion: suggestion
    }
  end
  let(:action_name) { :create }

  shared_examples "Allows the permission" do |scope:, allowed:|
    context "when subject is #{scope}" do
      let(:action_subject) { scope }

      it { is_expected.to be allowed }
    end
  end

  it_behaves_like "Allows the permission", scope: :suggestion_note, allowed: true
  it_behaves_like "Allows the permission", scope: :suggestion_answer, allowed: true
  it_behaves_like "Allows the permission", scope: :document_section, allowed: true
  it_behaves_like "Allows the permission", scope: :document_annotations, allowed: true
  it_behaves_like "Allows the permission", scope: :participatory_document, allowed: true
  it_behaves_like "Allows the permission", scope: :suggestions, allowed: true

  context "when user is valuator" do
    let(:valuator) { create :user, organization: organization }
    let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: component.participatory_space }
    let(:section1) { create(:participatory_documents_section, document: document) }
    let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }

    let(:user) { valuator }

    context "when is assigned" do
      let!(:assigned) { create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role }

      it_behaves_like "Allows the permission", scope: :suggestion_note, allowed: true
      it_behaves_like "Allows the permission", scope: :suggestion_answer, allowed: true
      it_behaves_like "Allows the permission", scope: :document_section, allowed: false
      it_behaves_like "Allows the permission", scope: :document_annotations, allowed: false
      it_behaves_like "Allows the permission", scope: :participatory_document, allowed: false
      it_behaves_like "Allows the permission", scope: :suggestions, allowed: false
    end

    context "when is not assigned" do
      it_behaves_like "Allows the permission", scope: :suggestion_note, allowed: false
      it_behaves_like "Allows the permission", scope: :suggestion_answer, allowed: false
      it_behaves_like "Allows the permission", scope: :document_section, allowed: false
      it_behaves_like "Allows the permission", scope: :document_annotations, allowed: false
      it_behaves_like "Allows the permission", scope: :participatory_document, allowed: false
      it_behaves_like "Allows the permission", scope: :suggestions, allowed: false
    end
  end
end
