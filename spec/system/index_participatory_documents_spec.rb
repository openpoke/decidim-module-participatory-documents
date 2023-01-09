# frozen_string_literal: true

require "spec_helper"

describe "Index participatory_documents", type: :system do
  include_context "with a component"
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:manifest_name) { "participatory_documents" }
  let!(:component) { create :participatory_documents_component, participatory_space: participatory_process }
  let!(:title) { "Test title" }
  let!(:description) { "Test description" }
  let!(:document) { create :participatory_documents_document, :with_file, title: { en: title }, description: { en: description }, component: component }

  before do
    visit_component
  end

  it "shows the index page" do
    expect(page).to have_css("iframe", id: "pdf-iframe")
  end

  context "when the document has no title or description" do
    let(:title) { nil }
    let(:description) { nil }

    it "does not show title and description" do
      expect(page).not_to have_content("Test title")
      expect(page).not_to have_content("Test description")
    end
  end

  context "when the document has a title and a description" do
    it "show title and description" do
      expect(page).to have_content("Test title")
      expect(page).to have_content("Test description")
    end
  end
end
