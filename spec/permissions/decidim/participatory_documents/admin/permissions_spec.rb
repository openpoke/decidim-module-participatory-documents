# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions }

  let(:component) { build :participatory_documents_component }
  let(:organization) { component.participatory_space.organization }
  let(:document) { create(:participatory_documents_document, component: component) }
  let(:user) { create :user, :admin, :confirmed, organization: component.organization }
  let(:permission_action) { Decidim::PermissionAction.new(scope: :admin, action: action_name, subject: action_subject) }
  let(:suggestion) { nil }
  let(:suggestion_note) { create(:participatory_documents_suggestion_note) }
  let(:context) do
    {
      current_component: component,
      current_settings: double(suggestion_answering_enabled: true),
      component_settings: double(suggestion_answering_enabled: true),
      suggestion: suggestion,
      suggestion_note: suggestion_note
    }
  end
  let(:action_name) { :create }

  shared_examples "Allows the permission" do |scope:, allowed:|
    context "when subject is #{scope}" do
      let(:action_subject) { scope }

      it do
        if allowed == true
          expect(subject.allowed?).to be allowed
        else
          expect { subject.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
        end
      end
    end
  end

  shared_examples "can add valuators to the suggestion" do
    describe "add other valuators" do
      let(:action_subject) { :suggestions }
      let(:action_name) { :assign_to_valuator }

      it { expect(subject.allowed?).to be true }
    end
  end

  shared_examples "cannot add valuators to the suggestion" do
    describe "add other valuators" do
      let(:action_subject) { :suggestions }
      let(:action_name) { :assign_to_valuator }

      # it { expect { subject.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError) }
      it { expect(subject.allowed?).to be true }
    end
  end

  shared_examples "edit suggestion note" do
    describe "edit suggestion note" do
      let(:action_subject) { :suggestion_note }
      let(:action_name) { :edit_note }
      let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
      let(:another_user) { create :user, :admin, :confirmed, organization: organization }

      context "when author edits his own note" do
        let!(:suggestion_note) { create(:participatory_documents_suggestion_note, suggestion: suggestion, author: user) }

        it { expect(subject.allowed?).to be true }
      end

      context "when the author of the note is a different user" do
        let!(:suggestion_note) { create(:participatory_documents_suggestion_note, suggestion: suggestion, author: another_user) }

        it { expect(subject.allowed?).to be false }
      end
    end
  end

  shared_examples "can create a suggestion note" do |allowed|
    let(:action_subject) { :suggestion_note }
    let(:action_name) { :create }

    it do
      if allowed
        expect(subject.allowed?).to be true
      else
        expect { subject.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
      end
    end
  end

  shared_examples "can create a suggestion answer" do |allowed|
    let(:action_subject) { :suggestion_answer }
    let(:action_name) { :create }

    it do
      if allowed
        expect(subject.allowed?).to be true
      else
        expect { subject.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
      end
    end
  end

  it_behaves_like "edit suggestion note"

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

    it_behaves_like "can add valuators to the suggestion"
    it_behaves_like "cannot add valuators to the suggestion"

    context "when is assigned" do
      let!(:assigned) { create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role }

      it_behaves_like "Allows the permission", scope: :suggestion_note, allowed: true
      it_behaves_like "Allows the permission", scope: :suggestion_answer, allowed: true
      it_behaves_like "Allows the permission", scope: :document_section, allowed: false
      it_behaves_like "Allows the permission", scope: :document_annotations, allowed: false
      it_behaves_like "Allows the permission", scope: :participatory_document, allowed: false
      it_behaves_like "Allows the permission", scope: :suggestions, allowed: false

      it_behaves_like "can create a suggestion note", true
      it_behaves_like "can create a suggestion answer", true
    end

    context "when is not assigned" do
      it_behaves_like "Allows the permission", scope: :suggestion_note, allowed: false
      it_behaves_like "Allows the permission", scope: :suggestion_answer, allowed: false
      it_behaves_like "Allows the permission", scope: :document_section, allowed: false
      it_behaves_like "Allows the permission", scope: :document_annotations, allowed: false
      it_behaves_like "Allows the permission", scope: :participatory_document, allowed: false
      it_behaves_like "Allows the permission", scope: :suggestions, allowed: false

      it_behaves_like "can create a suggestion note", false
      it_behaves_like "can create a suggestion answer", false
    end
  end
end
