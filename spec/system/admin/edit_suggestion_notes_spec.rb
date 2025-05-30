# frozen_string_literal: true

require "spec_helper"

describe "Edit Suggestion Notes" do
  let(:router) { Decidim::EngineRouter.admin_proxy(component).decidim_admin_participatory_process_participatory_documents }

  let(:component) { create(:participatory_documents_component) }
  let(:organization) { component.organization }
  let(:manifest_name) { "participatory_documents" }
  let!(:document) { create(:participatory_documents_document, :with_file, component:) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:participatory_space) { component.participatory_space }

  let(:body) { "Test body" }
  let(:suggestion_notes_count) { 5 }

  let!(:suggestion_notes) do
    create_list(
      :participatory_documents_suggestion_note,
      suggestion_notes_count,
      suggestion:,
      author:,
      body:
    )
  end

  include_context "when managing a component as an admin"

  before do
    visit router.document_suggestion_path(document, suggestion)
  end

  context "when the user is the author of the suggestion note" do
    let(:author) { user }

    before do
      click_on "Private notes"
    end

    it "shows suggestion notes for the current suggestion" do
      suggestion_notes.each do |suggestion_note|
        expect(page).to have_css(".link-alt")
        expect(page).to have_content(suggestion_note.author.name)
      end
    end

    it "edits a suggestion note" do
      within ".component__show_notes-grid .comment:last-child" do
        find(".link-alt").click
      end

      within "#editNoteModal#{suggestion_notes.last.id}" do
        expect(page).to have_content("Test body")
        fill_in :suggestion_note_body, with: "New awesome body"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully updated")
      click_on "Private notes"
      expect(page).to have_content("New awesome body")
    end
  end

  context "when the user is not the author of the suggestion note" do
    let(:author) { create(:user, organization:) }

    before do
      click_on "Private notes"
    end

    it "shows suggestion notes for the current suggestion" do
      suggestion_notes.each do |suggestion_note|
        expect(page).to have_no_css(".link-alt")
        expect(page).to have_content(suggestion_note.author.name)
      end
    end
  end

  context "when the note has not been edited" do
    let(:author) { user }

    it "does not display the edited status" do
      expect(page).to have_no_content("Edited")
    end
  end

  context "when the suggestion note has been edited" do
    let(:author) { user }

    before do
      suggestion_notes.last.update(body: "Edited body")
      visit current_path
      click_on "Private notes"
    end

    it "displays the edited status" do
      expect(page).to have_content("Edited")
      expect(page).to have_content(suggestion_notes.last.updated_at.strftime("%d/%m/%Y %H:%M"))
    end
  end
end
