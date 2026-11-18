# frozen_string_literal: true

require "spec_helper"

describe "User interaction with PDF viewer" do
  include_context "with a component"
  let(:manifest_name) { "participatory_documents" }

  let!(:user) { create(:user, :admin, :confirmed, organization: participatory_process.organization) }
  let!(:document) { create(:participatory_documents_document, :with_file, author: user, component:) }
  let!(:section) { create(:participatory_documents_section, :with_annotations, document:) }

  shared_examples "interacts with drawer" do
    it "displays the drawer" do
      expect(page).to have_css("#participationModal")
      expect(page).to have_css("#participation-modal-form")
      expect(page).to have_css("#suggestions-list")
    end

    context "when displaying the suggestions" do
      let(:other_user) { create(:user, :admin, :confirmed, organization: user.organization) }
      let!(:my_suggestion) { create(:participatory_documents_suggestion, suggestable:, author: user) }
      let!(:other_suggestion) { create(:participatory_documents_suggestion, suggestable:, author: other_user) }

      let(:attributes) { { suggestable:, author: user, answer:, answered_at: Time.zone.now, answer_is_published: published } }

      before do
        page.refresh
        find(drawer_trigger).click
      end

      it "displays only my suggestion" do
        within "#participationModal" do
          expect(page).to have_content(my_suggestion.body["en"])
          expect(page).to have_no_content(other_suggestion.body["en"])
        end
      end

      context "when admin interacts with my suggestion" do
        let(:answer) { { "en" => "A very cool idea" } }
        let(:published) { false }

        context "when admin saves a response with :not_answered state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :not_answered, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participationModal" do
                expect(page).to have_no_content(answer["en"])
              end
            end
          end

          context "when the answer is published" do
            let(:published) { true }

            it "does not render admin note" do
              within "#participationModal" do
                expect(page).to have_no_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :evaluating state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :evaluating, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participationModal" do
                expect(page).to have_no_content(answer["en"])
              end
            end
          end

          context "when the answer is published" do
            let(:published) { true }

            it "renders admin note" do
              within "#participationModal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :withdrawn state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :withdrawn, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participationModal" do
                expect(page).to have_no_content(answer["en"])
              end
            end
          end

          context "when the answer is published" do
            let(:published) { true }

            it "does not render admin note" do
              within "#participationModal" do
                expect(page).to have_no_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :rejected state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :rejected, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participationModal" do
                expect(page).to have_no_content(answer["en"])
              end
            end
          end

          context "when the answer is NOT draft" do
            let(:published) { true }

            it "renders admin note" do
              within "#participationModal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :accepted state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :accepted, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participationModal" do
                expect(page).to have_no_content(answer["en"])
              end
            end
          end

          context "when the answer is NOT draft" do
            let(:published) { true }

            it "renders admin note" do
              within "#participationModal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end
      end
    end
  end

  context "when providing feedback through boxes" do
    let(:suggestable) { section }
    let(:drawer_trigger) { "#box-#{section.annotations.last.id}" }

    before do
      login_as document.author, scope: :user

      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
      find(drawer_trigger).click
    end

    it "displays boxes in page" do
      section.annotations.each do |annotation|
        expect(page).to have_selector(:id, "box-#{annotation.id}")
      end
    end

    it_behaves_like "interacts with drawer"
  end

  context "when providing document feedback" do
    let(:suggestable) { document }
    let(:drawer_trigger) { "#globalSuggestionTrigger" }

    before do
      login_as document.author, scope: :user

      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
      find(drawer_trigger).click
    end

    it_behaves_like "interacts with drawer"
  end

  context "when adding a suggestion" do
    let!(:own_suggestions) { create_list(:participatory_documents_suggestion, 2, suggestable: document, author: user) }
    let!(:other_suggestions) { create_list(:participatory_documents_suggestion, 2) }

    before do
      login_as document.author, scope: :user

      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
    end

    it "submits a box content" do
      find("#box-#{section.annotations.first.id}").click
      expect(page).to have_css("#participationModal.active")
      expect(page).to have_content(t("activemodel.attributes.suggestion.body"))
      expect(page).to have_no_content("upload a file")

      within "#new_suggestion" do
        fill_in :suggestion_body, with: "Some random string longer than 15 chrs"
      end
      click_on("Send suggestion")
      expect(page).to have_content("Some random string longer than 15 chrs")
      find_by_id("close-suggestions").click
      expect(page).to have_no_content("Some random string longer than 15 chrs")
      page.find("#box-#{section.annotations.first.id}").click
      expect(page).to have_content("Some random string longer than 15 chrs")
    end

    it "submits a global content" do
      click_on "Global suggestions"
      expect(page).to have_css("#participationModal.active")
      expect(page).to have_content("upload a file")
      expect(page).to have_content(t("activemodel.attributes.suggestion.body"))

      within "#messageForm" do
        fill_in :suggestion_body, with: "Some random string longer than 15 chrs"
      end
      click_on("Send suggestion")
      expect(page).to have_content("Some random string longer than 15 chrs")
      find_by_id("close-suggestions").click
      expect(page).to have_no_content("Some random string longer than 15 chrs")
      click_on "Global suggestions"
      expect(page).to have_content("Some random string longer than 15 chrs")
    end

    it "attaches a file to consecutive global suggestions" do
      click_on "Global suggestions"

      2.times do |index|
        dynamically_attach_file(:suggestion_file, Decidim::Dev.asset("Exampledocument.pdf"))
        within "#messageForm" do
          fill_in :suggestion_body, with: "Suggestion number #{index} with a file"
        end
        click_on("Send suggestion")
        expect(page).to have_content("Suggestion number #{index} with a file")
      end

      expect(page).to have_css("#suggestions-list a[href*='Exampledocument.pdf']", count: 2)
    end

    it "attaches a file to a global suggestion after visiting a box panel" do
      find("#box-#{section.annotations.first.id}").click
      within "#participationModal" do
        expect(page).to have_content(translated(section.title))
      end

      click_on "Global suggestions"
      expect(page).to have_content("upload a file")
      dynamically_attach_file(:suggestion_file, Decidim::Dev.asset("Exampledocument.pdf"))
      within "#messageForm" do
        fill_in :suggestion_body, with: "Suggestion with a file after a box"
      end
      click_on("Send suggestion")

      within "#suggestions-list" do
        expect(page).to have_content("Suggestion with a file after a box")
        expect(page).to have_link(href: /Exampledocument\.pdf/)
      end
    end

    it "attaches a file of a type allowed by the organization" do
      click_on "Global suggestions"
      dynamically_attach_file(:suggestion_file, File.expand_path("../fixtures/files/suggestions.txt", __dir__))
      within "#messageForm" do
        fill_in :suggestion_body, with: "Suggestion with a text file"
      end
      click_on("Send suggestion")

      within "#suggestions-list" do
        expect(page).to have_content("Suggestion with a text file")
        expect(page).to have_link(href: /suggestions\.txt/)
      end
    end

    it "keeps a single upload dialog after sending several global suggestions" do
      click_on "Global suggestions"

      2.times do |index|
        within "#messageForm" do
          fill_in :suggestion_body, with: "Global suggestion number #{index}"
        end
        click_on("Send suggestion")
        expect(page).to have_content("Global suggestion number #{index}")
      end

      expect(page.evaluate_script("document.querySelectorAll('[data-dialog^=\"upload_\"]').length")).to eq(1)
    end

    context "when switching between areas" do
      let!(:other_section) { create(:participatory_documents_section, :with_annotations, document:) }
      let!(:section_suggestion) { create(:participatory_documents_suggestion, suggestable: section, author: user, body: { en: "Suggestion of the first area" }) }

      before do
        page.refresh
      end

      it "does not show the suggestions of the previous area while the new one is loading" do
        find("#box-#{section.annotations.first.id}").click
        expect(page).to have_content("Suggestion of the first area")
        find_by_id("close-suggestions").click
        expect(page).to have_no_content("Suggestion of the first area")

        page.execute_script("window.originalFetch = window.fetch; window.fetch = (...args) => new Promise((resolve) => setTimeout(() => resolve(window.originalFetch(...args)), 4000));")
        find("#box-#{other_section.annotations.first.id}").click

        within "#participationModal" do
          expect(page).to have_no_content("Suggestion of the first area", wait: 1)
          expect(page).to have_content(translated(other_section.title))
        end
      end
    end

    it "switches from the global panel to a box panel" do
      click_on "Global suggestions"
      expect(page).to have_css("#participationModal.active.document")

      find_by_id("close-suggestions").click
      find("#box-#{section.annotations.first.id}").click
      expect(page).to have_css("#participationModal.active.section")
      expect(page).to have_no_css("#participationModal.document")
      within "#participationModal" do
        expect(page).to have_content(translated(section.title))
      end

      find_by_id("close-suggestions").click
      expect(page).to have_no_css("#participationModal.active")
      expect(page).to have_no_css("#participationModal.section")
    end

    context "when the user exports own suggestions" do
      around do |example|
        original_setting = ActionController::Base.allow_forgery_protection
        ActionController::Base.allow_forgery_protection = true
        example.run
        ActionController::Base.allow_forgery_protection = original_setting
      end

      it "exports only his own suggestions" do
        click_on "Export my suggestions"
        expect(page).to have_content("You have 2 suggestions on this document")

        perform_enqueued_jobs do
          click_on "Send me my suggestions"
          expect(page).to have_content("2 suggestions have been successfully exported")
        end

        expect(last_email.subject).to include("Your export")
      end

      it "counts the suggestions created without reloading the page" do
        click_on "Global suggestions"
        within "#messageForm" do
          fill_in :suggestion_body, with: "Some random string longer than 15 chrs"
        end
        click_on("Send suggestion")
        expect(page).to have_content("Some random string longer than 15 chrs")
        find_by_id("close-suggestions").click
        expect(page).to have_no_content("Some random string longer than 15 chrs")

        click_on "Export my suggestions"
        expect(page).to have_content("You have 3 suggestions on this document")
      end

      it "lists the export in the download your data page" do
        click_on "Export my suggestions"

        perform_enqueued_jobs do
          click_on "Send me my suggestions"
          expect(page).to have_content("2 suggestions have been successfully exported")
        end

        visit decidim.download_your_data_path
        expect(page).to have_content("Suggestions export")
      end
    end
  end

  context "when the suggestion answer has a text with potential XSS" do
    let!(:document) { create(:participatory_documents_document, :with_file, component:) }
    let!(:suggestion) { create(:participatory_documents_suggestion, :accepted, :published, author: document.author, suggestable: document, answer: { en: answer }) }
    let(:answer) { '<p>Safe answer text<img src="about:blank" onerror="alert(777)"></p>' }

    before do
      login_as document.author, scope: :user
      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
      find_by_id("globalSuggestionTrigger").click
    end

    it "shows sanitized answer" do
      expect(page).to have_content("Safe answer text")
      expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
    end
  end

  context "when the answer of a suggestion is published" do
    let!(:suggestion) { create(:participatory_documents_suggestion, :accepted, :published, :with_answer, author: user, suggestable: document) }

    before do
      perform_enqueued_jobs { Decidim::ParticipatoryDocuments::Admin::NotifySuggestionAnswer.call(suggestion) }
      login_as user, scope: :user
      visit decidim.notifications_path
    end

    it "shows the notification to the author" do
      expect(page).to have_content("A suggestion you submitted on")
      expect(page).to have_content("document has been answered by an administrator")
    end
  end
end
