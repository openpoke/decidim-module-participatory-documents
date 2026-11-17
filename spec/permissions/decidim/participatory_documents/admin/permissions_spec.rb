# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:component) { create(:participatory_documents_component) }
  let(:organization) { component.organization }
  let(:document) { create(:participatory_documents_document, component:) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:suggestion) { nil }
  let(:suggestion_note) { nil }
  let(:context) do
    {
      current_component: component,
      current_settings: component.current_settings,
      component_settings: component.settings,
      document:,
      suggestion:,
      suggestion_note:
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  shared_examples "can create suggestion notes" do
    describe "suggestion note creation" do
      let(:action) { { scope: :admin, action: :create, subject: :suggestion_note } }

      it { is_expected.to be true }
    end
  end

  shared_examples "can answer suggestions" do
    describe "suggestion answering" do
      let(:action) { { scope: :admin, action: :update, subject: :suggestion_answer } }

      it { is_expected.to be true }
    end
  end

  shared_examples "cannot manage the document" do
    describe "section creation" do
      let(:action) { { scope: :admin, action: :create, subject: :document_section } }

      it_behaves_like "permission is not set"
    end

    describe "annotation creation" do
      let(:action) { { scope: :admin, action: :create, subject: :document_annotations } }

      it_behaves_like "permission is not set"
    end

    describe "document creation" do
      let(:action) { { scope: :admin, action: :create, subject: :participatory_document } }

      it_behaves_like "permission is not set"
    end

    describe "suggestions creation" do
      let(:action) { { scope: :admin, action: :create, subject: :suggestions } }

      it_behaves_like "permission is not set"
    end
  end

  it_behaves_like "can create suggestion notes"
  it_behaves_like "can answer suggestions"

  describe "section creation" do
    let(:action) { { scope: :admin, action: :create, subject: :document_section } }

    it { is_expected.to be true }
  end

  describe "annotation creation" do
    let(:action) { { scope: :admin, action: :create, subject: :document_annotations } }

    it { is_expected.to be true }
  end

  describe "document creation" do
    let(:action) { { scope: :admin, action: :create, subject: :participatory_document } }

    it { is_expected.to be true }
  end

  describe "suggestions creation" do
    let(:action) { { scope: :admin, action: :create, subject: :suggestions } }

    it { is_expected.to be true }
  end

  describe "answers publication" do
    let(:action) { { scope: :admin, action: :publish_answers, subject: :suggestion_answer } }

    it { is_expected.to be true }
  end

  context "when suggestion answering is disabled in the component" do
    let(:component) { create(:participatory_documents_component, settings: { suggestion_answering_enabled: false }) }

    describe "suggestion answering" do
      let(:action) { { scope: :admin, action: :update, subject: :suggestion_answer } }

      it { is_expected.to be false }
    end
  end

  context "when the document is published" do
    let(:document) { create(:participatory_documents_document, component:, published_at: Time.current) }

    describe "section edition" do
      let(:action) { { scope: :admin, action: :update, subject: :document_section } }

      it { is_expected.to be false }
    end

    describe "annotation creation" do
      let(:action) { { scope: :admin, action: :create, subject: :document_annotations } }

      it { is_expected.to be false }
    end
  end

  describe "suggestion note edition" do
    let(:action) { { scope: :admin, action: :edit_note, subject: :suggestion_note } }
    let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
    let(:suggestion_note) { create(:participatory_documents_suggestion_note, suggestion:, author:) }

    context "when the user is the author of the note" do
      let(:author) { user }

      it { is_expected.to be true }
    end

    context "when the author of the note is a different user" do
      let(:author) { create(:user, :admin, :confirmed, organization:) }

      it { is_expected.to be false }
    end
  end

  context "when user is an evaluator" do
    let(:user) { create(:user, organization:) }
    let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process: component.participatory_space) }
    let(:section) { create(:participatory_documents_section, document:) }
    let(:suggestion) { create(:participatory_documents_suggestion, suggestable: section) }

    context "and is assigned to the suggestion" do
      let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

      it_behaves_like "can create suggestion notes"
      it_behaves_like "can answer suggestions"
      it_behaves_like "cannot manage the document"

      describe "assign suggestions to an evaluator" do
        let(:action) { { scope: :admin, action: :assign_to_evaluator, subject: :suggestions } }

        it { is_expected.to be true }
      end

      describe "unassign suggestions from an evaluator" do
        let(:action) { { scope: :admin, action: :unassign_from_evaluator, subject: :suggestions } }
        let(:context) { super().merge(evaluator:) }

        context "when the evaluator unassigns themself" do
          let(:evaluator) { user }

          it { is_expected.to be true }
        end

        context "when the evaluator unassigns another evaluator" do
          let(:evaluator) { create(:user, organization:) }

          it_behaves_like "permission is not set"
        end
      end

      context "and suggestion answering is disabled in the component" do
        let(:component) { create(:participatory_documents_component, settings: { suggestion_answering_enabled: false }) }

        describe "suggestion answering" do
          let(:action) { { scope: :admin, action: :update, subject: :suggestion_answer } }

          it { is_expected.to be false }
        end
      end

      describe "suggestion note edition" do
        let(:action) { { scope: :admin, action: :edit_note, subject: :suggestion_note } }
        let(:suggestion_note) { create(:participatory_documents_suggestion_note, suggestion:, author:) }

        context "when the evaluator is the author of the note" do
          let(:author) { user }

          it { is_expected.to be true }
        end

        context "when the author of the note is a different user" do
          let(:author) { create(:user, :admin, :confirmed, organization:) }

          it { is_expected.to be false }
        end
      end
    end

    context "and is not assigned to the suggestion" do
      describe "suggestion note edition" do
        let(:action) { { scope: :admin, action: :edit_note, subject: :suggestion_note } }
        let(:suggestion_note) { create(:participatory_documents_suggestion_note, suggestion:, author: user) }

        it_behaves_like "permission is not set"
      end

      describe "suggestion note creation" do
        let(:action) { { scope: :admin, action: :create, subject: :suggestion_note } }

        it_behaves_like "permission is not set"
      end

      describe "suggestion answering" do
        let(:action) { { scope: :admin, action: :update, subject: :suggestion_answer } }

        it_behaves_like "permission is not set"
      end

      it_behaves_like "cannot manage the document"
    end
  end
end
