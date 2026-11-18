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
  let(:current_user) { user }

  before do
    login_as current_user, scope: :user if current_user
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

  it "sets the title of the page" do
    expect(page).to have_title(/Test title/)
  end

  context "when the description comes from the editor" do
    let(:description) { "<p>Test description</p>" }

    it "shows the description inside its block" do
      within ".description" do
        expect(page).to have_content("Test description")
      end
    end
  end

  it "does not scroll the page when the suggestions panel is closed" do
    within_frame "pdf-iframe" do
      click_on "Global suggestions"
      expect(page).to have_content("upload a file")
    end
    page.execute_script("window.scrollTo(0, 0)")
    within_frame "pdf-iframe" do
      page.execute_script("document.getElementById('close-suggestions').click()")
      expect(page).to have_no_content("upload a file")
    end

    expect(page.evaluate_script("window.scrollY")).to eq(0)
  end

  context "when the screen is narrow" do
    before do
      page.driver.browser.manage.window.resize_to(500, 844)
      visit_component
    end

    after do
      page.driver.browser.manage.window.resize_to(1920, 1080)
    end

    it "keeps the viewer aligned with the title" do
      offset = page.evaluate_script("document.querySelector('.pdf-viewer-container').getBoundingClientRect().left - document.querySelector('.content-block h3').getBoundingClientRect().left")

      expect(offset).to eq(0)
    end
  end

  context "when a visitor logs in from the login page" do
    let(:participant) { create(:user, :confirmed, organization:) }
    let(:current_user) { nil }

    it "comes back to the page of the document" do
      within_frame "pdf-iframe" do
        expect(page).to have_content("Global suggestions")
      end
      within "#main-bar" do
        click_on "Log in"
      end
      within "#session_new_user" do
        fill_in :session_user_email, with: participant.email
        fill_in :session_user_password, with: "decidim123456789"
        find("*[type=submit]").click
      end

      expect(page).to have_content("Test description")
      expect(page).to have_current_path(main_component_path(component))
    end
  end

  context "when a visitor accepts only the essential cookies" do
    let(:current_user) { nil }

    before do
      page.driver.browser.execute_cdp("Network.clearBrowserCookies")
      visit_component
      click_on "Accept only essential"
    end

    it "keeps showing the document" do
      expect(page).to have_no_content("You need to enable all cookies in order to see this content")
      within_frame "pdf-iframe" do
        expect(page).to have_content("Global suggestions")
      end
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
