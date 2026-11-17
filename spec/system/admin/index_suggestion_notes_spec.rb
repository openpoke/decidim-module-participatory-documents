# frozen_string_literal: true

require "spec_helper"

describe "Index Suggestion Notes" do
  let(:router) { Decidim::EngineRouter.admin_proxy(component).decidim_admin_participatory_process_participatory_documents }
  let(:manifest_name) { "participatory_documents" }
  let!(:document) { create(:participatory_documents_document, component:) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let(:body) { "New awesome body" }
  let(:suggestion_notes_count) { 5 }
  let!(:suggestion_notes) { create_list(:participatory_documents_suggestion_note, suggestion_notes_count, suggestion:) }

  include_context "when managing a component as an admin"

  before do
    visit router.document_suggestion_path(document, suggestion)

    click_on("Private notes")
  end

  it "shows suggestion notes for the current suggestion" do
    suggestion_notes.each do |suggestion_note|
      expect(page).to have_content(suggestion_note.author.name)
      expect(page).to have_content(suggestion_note.body)
    end
    expect(page).to have_css("form")
  end

  context "when the form has a text inside body" do
    it "creates a suggestion note", :slow do
      within ".new_suggestion_note" do
        fill_in :suggestion_note_body, with: body

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("Suggestion note successfully created")

      click_on("Private notes")

      within ".component__show_notes-grid" do
        expect(page).to have_content("New awesome body")
      end
    end
  end

  context "when the form hasn't text inside body" do
    let(:body) { nil }

    it "don't create a suggestion note", :slow do
      within ".new_suggestion_note" do
        fill_in :suggestion_note_body, with: body

        find("*[type=submit]").click
      end

      expect(page).to have_content("There is an error in this field.")
    end
  end
end
