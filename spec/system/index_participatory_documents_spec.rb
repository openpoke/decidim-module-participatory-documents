# frozen_string_literal: true

require "spec_helper"

describe "Index participatory_documents", type: :system do
  include_context "with a component"
  let(:organization) { create :organization }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:manifest_name) { "participatory_documents" }
  let!(:component) { create :participatory_documents_component, participatory_space: participatory_process }
  let!(:component_unpublished) { create :participatory_documents_component, :unpublished, participatory_space: participatory_process }
  let!(:title) { "Test title" }
  let!(:description) { "Test description" }
  let!(:document) { create :participatory_documents_document, :with_file, title: { en: title }, description: { en: description }, component: component }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component
  end

  context "when document is not uploaded" do
    let!(:document) { nil }

    it "shows a message" do
      expect(page).to have_content("There is no document uploaded yet")
    end
  end

  context "when component not published and document is uploaded" do
    let!(:component) { component_unpublished }

    it "shows a message" do
      expect(page).not_to have_content("There is no document uploaded yet")
      expect(page).to have_content(document.title["en"])
    end
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

  # TODO: Fix this test
  # context "when user goes to fullscreen mode" do
  #   it "changes button text and class" do
  #     within_frame("pdf-iframe") do
  #       button = find("#fullscreenButton")
  #
  #       expect(button.text).to eq("Fullscreen")
  #       expect(button[:class]).not_to include("exit")
  #
  #       button.click
  #
  #       expect(button).to have_text("Exit Fullscreen")
  #       expect(button[:class]).to include("exit")
  #
  #       button.click
  #
  #       expect(button.text).to eq("Fullscreen")
  #       expect(button[:class]).not_to include("exit")
  #     end
  #   end
  # end
end
