# frozen_string_literal: true

require "spec_helper"

describe "Admin edits participatory areas" do
  let(:manifest_name) { "participatory_documents" }
  let!(:document) { create(:participatory_documents_document, :with_file, component:) }
  let(:first_section) { create(:participatory_documents_section, document:) }
  let(:second_section) { create(:participatory_documents_section, document:) }
  let!(:areas) do
    [[first_section, 5], [second_section, 20], [first_section, 35], [first_section, 50]].map do |section, top|
      create(:participatory_documents_annotation, section:, rect: { left: 10, top:, width: 20, height: 8 })
    end
  end

  include_context "when managing a component as an admin"

  around do |example|
    original_setting = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    example.run
    ActionController::Base.allow_forgery_protection = original_setting
  end

  before do
    document.update_positions!
    visit Decidim::EngineRouter.admin_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
  end

  it "keeps the section numbers of the existing areas when a new area is drawn" do
    find_by_id("box-#{areas.last.id}")
    layer = page.evaluate_script("document.querySelector('.polygon-ready').getBoundingClientRect().toJSON()")

    page.driver.browser.action
        .move_to_location((layer["x"] + (layer["width"] * 0.6)).round, (layer["y"] + (layer["height"] * 0.08)).round)
        .click_and_hold
        .move_by((layer["width"] * 0.1).round, (layer["height"] * 0.03).round)
        .move_by((layer["width"] * 0.1).round, (layer["height"] * 0.03).round)
        .release
        .perform

    numbers = page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll(".polygon-ready .box"))
        .sort((first, second) => parseFloat(first.style.top) - parseFloat(second.style.top))
        .map((box) => box.dataset.sectionNumber)
    JS

    expect(numbers).to eq(%w(1 2 3 1 1))
  end

  it "keeps the area when the title of its section is changed" do
    find_by_id("box-#{areas.first.id}").click
    within "#editor-modal" do
      fill_in_i18n(:section_title, "#section-title-tabs", en: "Renamed section")
      click_on "Save"
    end

    expect(page).to have_content("The area has been created")
    expect(page).to have_selector(:id, "box-#{areas.first.id}")
    expect(translated(first_section.reload.title)).to eq("Renamed section")
  end

  context "when the section has no title" do
    let(:first_section) { create(:participatory_documents_section, document:, title: nil) }

    it "stores only the languages filled in by the admin" do
      find_by_id("box-#{areas.first.id}").click
      within "#editor-modal" do
        fill_in_i18n(:section_title, "#section-title-tabs", en: "Renamed section")
        click_on "Save"
      end

      expect(page).to have_content("The area has been created")
      expect(first_section.reload[:title]).to eq("en" => "Renamed section")
    end
  end

  it "removes an area" do
    find_by_id("box-#{areas.second.id}").click
    within "#editor-modal" do
      click_on "Delete"
    end
    page.driver.browser.switch_to.alert.accept

    expect(page).to have_content("The area has been removed")
    expect(page).to have_no_selector(:id, "box-#{areas.second.id}")
    expect(Decidim::ParticipatoryDocuments::Annotation.count).to eq(3)
  end

  context "when the area is not in the page being viewed" do
    let(:seeds_file) { Decidim::ParticipatoryDocuments::Engine.root.join("lib/decidim/participatory_documents/seeds/Exampledocument.pdf") }
    let!(:document) { create(:participatory_documents_document, component:, file: Rack::Test::UploadedFile.new(seeds_file, "application/pdf")) }
    let!(:areas) { [create(:participatory_documents_annotation, section: first_section, page_number: 2, rect: { left: 10, top: 2, width: 20, height: 5 })] }

    it "keeps the area in its page when the title of its section is changed" do
      find_by_id("box-#{areas.first.id}").click
      within "#editor-modal" do
        fill_in_i18n(:section_title, "#section-title-tabs", en: "Renamed section")
        click_on "Save"
      end

      expect(page).to have_content("The area has been created")
      expect(areas.first.reload.page_number).to eq(2)
    end
  end

  context "when the document has no areas" do
    let(:areas) { [] }

    it "saves an area after clicking save with nothing to save" do
      expect(page).to have_content("Start creating areas for participation")
      click_on "Save changes!"

      layer = page.evaluate_script("document.querySelector('.polygon-ready').getBoundingClientRect().toJSON()")

      page.driver.browser.action
          .move_to_location((layer["x"] + (layer["width"] * 0.6)).round, (layer["y"] + (layer["height"] * 0.08)).round)
          .click_and_hold
          .move_by((layer["width"] * 0.1).round, (layer["height"] * 0.03).round)
          .move_by((layer["width"] * 0.1).round, (layer["height"] * 0.03).round)
          .release
          .perform

      click_on "Save changes!"
      expect(page).to have_content("All the areas have been saved successfully")
      expect(Decidim::ParticipatoryDocuments::Annotation.count).to eq(1)
    end
  end
end
