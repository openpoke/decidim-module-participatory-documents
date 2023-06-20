# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory documents", type: :system do
  let(:manifest_name) { "participatory_documents" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:default_color) { "rgb(30, 152, 215)" }
  let(:default_color_with_opacity) { "rgba(30, 152, 215, 0.12)" }

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

  shared_examples "creating a document" do |create|
    it "has the fields" do
      expect(page).to have_content("Add images by dragging & dropping or pasting them.")
      expect(page.execute_script("return window.getComputedStyle(document.querySelector('.box-preview .box')).backgroundColor")).to eq(default_color_with_opacity)
      expect(page.execute_script("return window.getComputedStyle(document.querySelector('.box-preview .box')).borderColor")).to eq(default_color)

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
        fill_in :document_box_opacity, with: "50"
        fill_in :document_box_color, with: "#f00f00"
        attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf")

        expect(page.execute_script("return window.getComputedStyle(document.querySelector('.box-preview .box')).backgroundColor")).to eq("rgba(240, 15, 0, 0.498)")
        expect(page.execute_script("return window.getComputedStyle(document.querySelector('.box-preview .box')).borderColor")).to eq("rgb(240, 15, 0)")

        if create
          click_button "Create participatory document"
        else
          click_button "Update"
        end
      end
      if create
        expect(page).to have_content("Document has been successfully created")
        # redirect to edit page
        expect(page).to have_content("Back")
        expect(page).to have_css(".pdf-viewer-container")
      else
        expect(page).to have_content("Document has been successfully updated")
      end
    end
  end

  context "when attaching a file" do
    before do
      click_link "Upload PDF document"
    end

    it_behaves_like "creating a document", true

    it "has no areas delete warning" do
      expect(page).not_to have_content("all the participatory areas will be deleted!")
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

  context "when document is updated" do
    let!(:document) { create :participatory_documents_document, :with_file, component: component }
    let(:default_color) { "rgb(250, 170, 170)" }
    let!(:default_color_with_opacity) { "rgba(250, 170, 170, 0.2)" }

    before do
      visit_component_admin
      click_on "Edit/upload document"
    end

    it_behaves_like "creating a document", false

    it "has no sections delete warning" do
      expect(page).not_to have_content("all the participatory areas will be deleted!")
    end

    context "when document has areas" do
      let!(:document) { create :participatory_documents_document, :with_file, :with_sections, component: component }

      it "has sections delete warning" do
        expect(page).to have_content("all the participatory areas will be deleted!")
        expect(document.sections.count).to eq(2)
        attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf")
        click_button "Update"
        expect(document.sections.reload.count).to eq(0)
      end

      context "and areas have suggestions" do
        let!(:document) { create :participatory_documents_document, :with_file, :with_annotations, component: component }

        it "do not remove the document" do
          expect(page).not_to have_content("all the participatory areas will be deleted!")
          expect(page).to have_content("This document cannot be changed or removed because it already has suggestions attached")
          expect(document.sections.count).to eq(2)
          attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf")
          click_button "Update"
          expect(document.sections.reload.count).to eq(2)
          expect(page).to have_content("Cannot delete record because dependent annotations exist")
        end

        it "updates other parts of the document" do
          fill_in_i18n_editor(
            :document_description,
            "#document-description-tabs",
            en: "This is description of the file"
          )
          click_button "Update"
          expect(page).to have_content("Document has been successfully updated")
          expect(document.reload.description["en"]).to include("This is description of the file")
        end
      end
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
