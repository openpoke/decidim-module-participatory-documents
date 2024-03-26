# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory documents" do
  let(:manifest_name) { "participatory_documents" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:default_color) { "rgb(30, 152, 215)" }
  let(:default_color_with_opacity) { "rgba(30, 152, 215, 0.12)" }

  include_context "when managing a component as an admin"

  context "when document is not created" do
    it "shows the upload button" do
      visit_component_admin

      expect(page).to have_content("Please upload a PDF to start")
      expect(page).to have_no_link("Edit participatory areas")
      expect(page).to have_link("Upload PDF document")
    end
  end

  shared_examples "creating a document" do |create|
    it "has the fields" do
      expect(page).to have_content("Add file") if create
      expect(page).to have_content("Replace") unless create
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
      end
      dynamically_attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf"), remove_before: create.blank?

      expect(page.execute_script("return window.getComputedStyle(document.querySelector('.box-preview .box')).backgroundColor")).to eq("rgba(240, 15, 0, 0.498)")
      expect(page.execute_script("return window.getComputedStyle(document.querySelector('.box-preview .box')).borderColor")).to eq("rgb(240, 15, 0)")

      if create
        click_link_or_button "Create participatory document"
      else
        click_link_or_button "Update"
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
      click_link_or_button "Upload PDF document"
    end

    it_behaves_like "creating a document", true

    it "has no areas delete warning" do
      expect(page).to have_no_content("all the participatory areas will be deleted!")
    end

    context "when file has a virus" do
      before do
        AntivirusValidator.fake_virus = true
      end

      after do
        AntivirusValidator.fake_virus = false
      end

      it "shows an error" do
        within ".documents_form" do
          fill_in_i18n(
            :document_title,
            "#document-title-tabs",
            en: "This is my document"
          )
        end
        dynamically_attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf"), keep_modal_open: true
        expect(page).to have_content("errors.messages.virus")
      end
    end
  end

  context "when a file is not uploaded" do
    let!(:document) { create(:participatory_documents_document, component:) }

    it "shows the upload button" do
      visit_component_admin

      expect(page).to have_content("Please upload a PDF to start")
      expect(page).to have_no_link("Edit participatory areas")
      expect(page).to have_link("Edit/upload document")
    end
  end

  context "when document is updated" do
    let!(:document) { create(:participatory_documents_document, :with_file, component:) }
    let(:default_color) { "rgb(250, 170, 170)" }
    let!(:default_color_with_opacity) { "rgba(250, 170, 170, 0.2)" }

    before do
      visit_component_admin
      click_on "Edit/upload document"
    end

    it_behaves_like "creating a document", false

    it "has no sections delete warning" do
      expect(page).to have_no_content("all the participatory areas will be deleted!")
    end

    shared_examples "removes sections" do
      it "has sections delete warning" do
        expect(page).to have_content("all the participatory areas will be deleted!")
        expect(document.sections.count).to eq(2)
        dynamically_attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf"), remove_before: true
        click_link_or_button "Update"
        expect(document.sections.reload.count).to eq(0)
      end
    end

    shared_examples "does not remove sections" do |with_sections|
      it "do not remove the document" do
        expect(page).to have_no_content("all the participatory areas will be deleted!")
        expect(page).to have_content("This document cannot be changed or removed because it already has suggestions attached")
        expect(document.sections.count).to eq(2) if with_sections
        dynamically_attach_file :document_file, Decidim::Dev.asset("Exampledocument.pdf"), remove_before: true
        click_link_or_button "Update"
        expect(document.sections.reload.count).to eq(2) if with_sections
        expect(page).to have_content("This document cannot be changed or removed because it has suggestions")
      end

      it "updates other parts of the document" do
        fill_in_i18n_editor(
          :document_description,
          "#document-description-tabs",
          en: "This is description of the file"
        )
        click_link_or_button "Update"
        expect(page).to have_content("Document has been successfully updated")
        expect(document.reload.description["en"]).to include("This is description of the file")
      end
    end

    context "when document has sections" do
      let!(:document) { create(:participatory_documents_document, :with_file, :with_sections, component:) }

      it_behaves_like "removes sections"

      context "and have global suggestions" do
        let!(:document) { create(:participatory_documents_document, :with_file, :with_global_suggestions, component:) }

        it_behaves_like "does not remove sections", false
      end

      context "and areas have annotations (boxes)" do
        let!(:document) { create(:participatory_documents_document, :with_file, :with_annotations, component:) }

        it_behaves_like "removes sections"
      end

      context "and areas have suggestions" do
        let!(:document) { create(:participatory_documents_document, :with_file, :with_suggestions, component:) }

        it_behaves_like "does not remove sections", true
      end
    end
  end

  context "when a file is uploaded" do
    let!(:document) { create(:participatory_documents_document, :with_file, component:) }

    it "shows the edit buttons" do
      visit_component_admin

      expect(page).to have_link("Edit participatory areas")
      expect(page).to have_link("Edit/upload document")
      expect(page).to have_content("List Suggestions")
    end
  end

  context "when the admin wants to publish sections of the document" do
    let!(:document) { create(:participatory_documents_document, :with_file, component:) }
    let!(:section) { create(:participatory_documents_section, document:) }
    let!(:section2) { create(:participatory_documents_section, document:) }
    let!(:section3) { create(:participatory_documents_section, document:) }

    before do
      visit_component_admin
    end

    it "shows the preview button" do
      expect(page).to have_link("Preview and publish sections")
    end

    context "when in the editor" do
      before do
        click_link_or_button "Edit participatory areas"
      end

      it "shows the preview button" do
        expect(page).to have_link("Preview and publish sections")
      end

      it "goes to the preview page" do
        click_link_or_button "Preview and publish sections"
        expect(page).to have_content("you are previewing the participatory sections of the document")
      end
    end

    context "when previewing the document" do
      before do
        click_link_or_button "Preview and publish sections"
      end

      it "displays the preview content" do
        expect(page).to have_content("you are previewing the participatory sections of the document")
      end

      it "can edit sections after previewing" do
        click_link_or_button "Go back to edit participatory sections"
        expect(page).to have_css("a[href='#{manage_component_path(component)}'][title='Back']")
      end

      it "can publish sections" do
        click_link_or_button "Publish participatory sections"
        expect(page).to have_content("are you sure?")
        click_link_or_button "OK"
        expect(page).to have_content("Sections have been successfully published")
      end
    end

    context "when the document has been published" do
      before do
        click_link_or_button "Preview and publish sections"
        click_link_or_button "Publish participatory sections"
        click_link_or_button "OK"
      end

      it "restricts editing sections" do
        expect(page).to have_no_content("Edit/upload document")
        expect(page).to have_no_content("Edit participatory areas")
        expect(page).to have_no_content("Preview and publish sections")
      end
    end
  end
end
