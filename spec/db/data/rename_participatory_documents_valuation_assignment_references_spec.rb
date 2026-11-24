# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261111150000_rename_participatory_documents_valuation_assignment_references"

describe RenameParticipatoryDocumentsValuationAssignmentReferences do
  let(:migrator) { described_class.new.tap { |m| m.verbose = false } }
  let(:old_type) { "Decidim::ParticipatoryDocuments::ValuationAssignment" }
  let(:new_type) { "Decidim::ParticipatoryDocuments::EvaluationAssignment" }

  let(:document) { create(:participatory_documents_document) }
  let(:organization) { document.component.organization }
  let(:user) { create(:user, organization:) }
  let(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: create(:user, organization:), participatory_process: document.component.participatory_space) }
  let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }
  let!(:action_log_with_other_type) { create(:action_log, user:, resource: suggestion) }
  let!(:action_logs_with_old_type) do
    # rubocop:disable Rails/SkipsModelValidations
    Decidim::ActionLog.insert_all([
                                    {
                                      decidim_organization_id: organization.id,
                                      user_id: user.id,
                                      user_type: "Decidim::User",
                                      resource_type: old_type,
                                      resource_id: assignment.id,
                                      action: "create",
                                      visibility: "admin-only",
                                      extra: {
                                        "user" => {
                                          "ip" => "127.0.0.1",
                                          "name" => "Dummy user",
                                          "nickname" => "dummy"
                                        },
                                        "resource" => {},
                                        "component" => {},
                                        "participatory_space" => {}
                                      },
                                      created_at: Time.current,
                                      updated_at: Time.current
                                    }
                                  ])
    # rubocop:enable Rails/SkipsModelValidations
  end

  it "updates properly the action logs" do
    expect(Decidim::ActionLog.where(resource_type: new_type).first).to be_nil

    migrator.migrate(:up)
    expect(Decidim::ActionLog.where(resource_type: new_type).first.resource).to eq(assignment)
    expect(Decidim::ActionLog.where(resource_type: old_type).first).to be_nil
    expect(action_log_with_other_type.reload.resource).to eq(suggestion)

    migrator.migrate(:down)
    expect(Decidim::ActionLog.where(resource_type: new_type).first).to be_nil
    expect(Decidim::ActionLog.where(resource_type: old_type).first.resource_id).to eq(assignment.id)
    expect(action_log_with_other_type.reload.resource).to eq(suggestion)
  end

  it "updates properly the paper trail versions" do
    described_class::Version.create!(
      item_type: old_type,
      item_id: assignment.id,
      event: "create",
      whodunnit: user.id.to_s,
      object: "{}",
      object_changes: "{}",
      created_at: Time.current
    )

    expect(described_class::Version.where(item_type: new_type).first).to be_nil

    migrator.migrate(:up)
    expect(described_class::Version.where(item_type: new_type).first.item_id).to eq(assignment.id)

    migrator.migrate(:down)
    expect(described_class::Version.where(item_type: new_type).first).to be_nil
  end

  context "when there are no records with the old type" do
    let!(:action_logs_with_old_type) { [] }

    it "does not raise an error" do
      expect { migrator.migrate(:up) }.not_to raise_error
    end
  end
end
