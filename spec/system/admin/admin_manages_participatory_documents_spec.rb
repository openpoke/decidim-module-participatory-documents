# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory documents", type: :system do
  let(:manifest_name) { "participatory_documents" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }

  def upload_file
    document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")
  end

  include_context "when managing a component as an admin"

  context "when document is not created" do
    it "shows the upload button" do
      visit_component_admin

      expect(page).to have_content("Please upload a PDF to start")
      expect(page).not_to have_link("Edit participatory areas")
      expect(page).to have_link("Upload PDF document")
    end
  end

  context "when attaching a file" do
    before do
      click_link "Upload PDF document"
    end

    it "has the fields" do
      expect(page).to have_content("Add images by dragging & dropping or pasting them.")

      within ".documents_form" do
        fill_in_i18n(
          :document_title,
          "#document-title-tabs",
          en: "This is my document"
        )
        fill_in_i18n_editor(
          :document_description,
          "#document-description-tabs",
          en: "This is description of the file"
        )
        attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf")
        click_button "Create Participatory document"
      end
      expect(page).to have_content("Document has been successfully created")
    end
  end

  context "when a file is not uploaded" do
    let!(:document) { create :participatory_documents_document, component: component }

    it "shows the upload button" do
      visit_component_admin

      expect(page).to have_content("Please upload a PDF to start")
      expect(page).not_to have_link("Edit participatory areas")
      expect(page).to have_link("Edit/upload document")
    end
  end

  context "when document needs update" do
    let!(:document) { create :participatory_documents_document, component: component }

    before do
      visit_component_admin
      click_on "Edit/upload document"
    end

    it "has the fields" do
      expect(page).to have_content("Add images by dragging & dropping or pasting them.")

      within ".documents_form" do
        fill_in_i18n(
          :document_title,
          "#document-title-tabs",
          en: "This is my document"
        )
        fill_in_i18n_editor(
          :document_description,
          "#document-description-tabs",
          en: "This is description of the file"
        )
        attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf")
        click_button "Update"
      end
      expect(page).to have_content("Document has been successfully updated")
    end
  end

  context "when a file is uploaded" do
    let!(:document) { create :participatory_documents_document, component: component }

    before do
      upload_file
    end

    it "shows the edit buttons" do
      visit_component_admin

      expect(page).to have_link("Edit participatory areas")
      expect(page).to have_link("Edit/upload document")
      expect(page).to have_content("List Suggestions")
    end
  end
end
