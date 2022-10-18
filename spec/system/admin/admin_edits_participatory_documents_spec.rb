# frozen_string_literal: true

require "spec_helper"

describe "Admin edits participatory documents", type: :system do
  let(:manifest_name) { "participatory_documents" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:document) { create :participatory_documents_document, component: component }

  include_context "when managing a component as an admin"

  it "shows the editing page" do
    visit_component_admin

    expect(page).to have_content("Participatory document admin placeholder")
  end
end
