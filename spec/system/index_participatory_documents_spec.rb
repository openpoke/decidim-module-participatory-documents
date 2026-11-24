# frozen_string_literal: true

require "spec_helper"

describe "Index participatory_documents" do
  include_context "with a component"
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:manifest_name) { "participatory_documents" }
  let!(:component) { create(:participatory_documents_component, participatory_space: participatory_process) }
  let!(:component_unpublished) { create(:participatory_documents_component, :unpublished, participatory_space: participatory_process) }
  let(:title) { "Test title" }
  let(:description) { "Test description" }
  let!(:document) { create(:participatory_documents_document, :with_file, title: { en: title }, description: { en: description }, component:) }

  before do
    login_as user, scope: :user
    visit_component
  end

  context "when document is not uploaded" do
    let(:document) { nil }

    it "shows a message" do
      expect(page).to have_content("There is no document uploaded yet")
    end
  end

  context "when component not published and document is uploaded" do
    let(:component) { component_unpublished }

    it "shows the document" do
      expect(page).to have_no_content("There is no document uploaded yet")
      expect(page).to have_content(document.title["en"])
    end
  end

  it "shows the index page" do
    expect(page).to have_css(".pdf-viewer-container")
    expect(page).to have_css("iframe#pdf-iframe")
    expect(page).to have_no_content("You need to enable all cookies in order to see this content")
  end

  context "when the document has no title or description" do
    let(:title) { nil }
    let(:description) { nil }

    it "does not show title and description" do
      expect(page).to have_no_content("Test title")
      expect(page).to have_no_content("Test description")
    end
  end

  context "when the document has a title and a description" do
    it "shows title and description" do
      expect(page).to have_content("Test title")
      expect(page).to have_content("Test description")
    end
  end

  context "when the document has a description with potential XSS" do
    let(:title) { '<p>Safe title text<img src="about:blank" onerror="alert(777)"></p>' }
    let(:description) { '<p>Safe description text<img src="about:blank" onerror="alert(777)"></p>' }

    it "shows sanitized title and description" do
      expect(page).to have_content("Safe title text")
      expect(page).to have_content("Safe description text")
      expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
    end
  end
end
