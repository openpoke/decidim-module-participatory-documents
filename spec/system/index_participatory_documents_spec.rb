# frozen_string_literal: true

require "spec_helper"

describe "Index participatory_documents", type: :system do
  include_context "with a component"
  let(:manifest_name) { "participatory_documents" }

  describe "file is not attached to the document" do
    let!(:document) { create :participatory_documents_document, component: component }
    let!(:document_title) { translated(document.title) }
    let!(:document_description) { translated(document.description) }

    context "when the title is blank" do
      before do
        visit_component
      end

      it "has title" do
        expect(page).to have_content(document_title)
      end

      it "has description" do
        expect(page).to have_content(document_description)
      end

      it "has not button" do
        expect(page).to have_content("The document is not ready")
      end
    end
  end

  describe "file is attached to the document" do
    let!(:document) { create :participatory_documents_document, :with_file, component: component }
    let!(:document_title) { translated(document.title) }
    let!(:document_description) { translated(document.description) }

    context "when the title and description are blank" do
      before do
        visit_component
      end

      it "has title" do
        expect(page).to have_content(document_title)
      end

      it "has description" do
        expect(page).to have_content(document_description)
      end

      it "has button" do
        expect(page).to have_content("Participate now!")
      end

      it "redirect to pdf" do
        click_link("Participate now!")

        expect(page).to have_css("iframe", id: "pdf-iframe")
      end
    end
  end

  describe "the document is not created" do
    it "has not title, description, button" do
      visit_component

      expect(page).to have_content("The component is not ready")
    end
  end
end
