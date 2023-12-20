# frozen_string_literal: true

require "spec_helper"

describe "User interaction with PDF viewer", type: :system do
  include_context "with a component"
  let(:manifest_name) { "participatory_documents" }

  let!(:user) { create :user, :admin, :confirmed, organization: participatory_process.organization }
  let!(:document) { create(:participatory_documents_document, :with_file, author: user, component: component) }
  let!(:section) { create(:participatory_documents_section, :with_annotations, document: document) }

  shared_examples "interacts with drawer" do
    it "displays the drawer" do
      expect(page).to have_selector("#participation-modal")
      expect(page).to have_selector("#participation-modal-form")
      expect(page).to have_selector("#suggestions-list")
    end

    context "when displaying the suggestions" do
      let(:other_user) { create :user, :admin, :confirmed, organization: user.organization }
      let!(:my_suggestion) { create(:participatory_documents_suggestion, suggestable: sugested, author: user) }
      let!(:other_suggestion) { create(:participatory_documents_suggestion, suggestable: sugested, author: other_user) }

      let(:attributes) { { suggestable: sugested, author: user, answer: answer, answered_at: Time.zone.now, answer_is_published: published } }

      it "displays only my suggestion" do
        within "#participation-modal" do
          expect(page).to have_content(my_suggestion.body["en"])
          expect(page).not_to have_content(other_suggestion.body["en"])
        end
      end

      context "when admin interacts with my suggestion" do
        let(:answer) { { "en" => "A very cool idea" } }
        let(:published) { false }

        context "when admin saves a response with :not_answered state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :not_answered, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is published" do
            let(:published) { true }

            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :evaluating state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :evaluating, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is published" do
            let(:published) { true }

            it "renders admin note" do
              within "#participation-modal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :withdrawn state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :withdrawn, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is published" do
            let(:published) { true }

            it "renders admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :rejected state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :rejected, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is NOT draft" do
            let(:published) { true }

            it "renders admin note" do
              within "#participation-modal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :accepted state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :accepted, **attributes) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is NOT draft" do
            let(:published) { true }

            it "renders admin note" do
              within "#participation-modal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end
      end
    end
  end

  context "when providing feedback through boxes" do
    let(:sugested) { section }

    before do
      login_as document.author, scope: :user

      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
      annotation = section.annotations.last
      find("#box-#{annotation.id}").click
    end

    it "displays boxes in page" do
      section.annotations.each do |annotation|
        expect(page).to have_selector(:id, "box-#{annotation.id}")
      end
    end

    it_behaves_like "interacts with drawer"
  end

  context "when providing document feedback" do
    let(:sugested) { document }

    before do
      login_as document.author, scope: :user

      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
      find("#globalSuggestionTrigger").click
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
      sleep 1
      expect(page).to have_css("#participation-modal.active")
      expect(page).not_to have_content("upload a file")
      expect(page).to have_content(t("activemodel.attributes.suggestion.body"))

      within "#new_suggestion_" do
        fill_in :suggestion_body, with: "Some random string longer than 15 chrs"
        click_button("Send suggestion")
      end
      expect(page).to have_content("Some random string longer than 15 chrs")
      # hide the modal
      find("#close-suggestions").click
      expect(page).not_to have_content("Some random string longer than 15 chrs")
      page.find("#box-#{section.annotations.first.id}").click
      expect(page).to have_content("Some random string longer than 15 chrs")
    end

    it "submits a global content" do
      click_button "Global suggestions"
      sleep 1
      expect(page).to have_css("#participation-modal.active")
      expect(page).to have_content("upload a file")
      expect(page).to have_content(t("activemodel.attributes.suggestion.body"))

      within "#new_suggestion_" do
        fill_in :suggestion_body, with: "Some random string longer than 15 chrs"
        click_button("Send suggestion")
      end
      expect(page).to have_content("Some random string longer than 15 chrs")
      # hide the modal
      find("#close-suggestions").click
      expect(page).not_to have_content("Some random string longer than 15 chrs")
      click_button "Global suggestions"
      expect(page).to have_content("Some random string longer than 15 chrs")
    end

    context "when the user exports own suggestions", js: true do
      around do |example|
        original_setting = ActionController::Base.allow_forgery_protection
        ActionController::Base.allow_forgery_protection = true
        example.run
        ActionController::Base.allow_forgery_protection = original_setting
      end

      it "exports only his own suggestions" do
        click_button "Export my suggestions"
        expect(page).to have_content("You have 2 suggestions on this document")

        click_button "Send me my suggestions"
        sleep 1
        perform_enqueued_jobs

        expect(page).to have_content("2 suggestions have been successfully exported")

        expect(last_email.subject).to include("Your export", "xlsx")
        expect(last_email.attachments.length).to be_positive
        expect(last_email.attachments.first.filename).to match(/^suggestions.*\.zip$/)

        attachment = last_email.attachments.last

        Zip::File.open_buffer(attachment.body.raw_source) do |zip_file|
          xlsx_file_entry = zip_file.glob("*.xlsx").first

          Tempfile.create(%w(temp .xlsx), encoding: "ascii-8bit") do |tempfile|
            tempfile.write(xlsx_file_entry.get_input_stream.read)
            tempfile.rewind

            workbook = RubyXL::Parser.parse(tempfile.path)
            worksheet = workbook[0]

            xlsx_data_length = worksheet.count

            expect(xlsx_data_length).to eq(3) # header + 2 rows
          end
        end
      end
    end
  end

  context "when the suggestion answer has a text with potential XSS" do
    let!(:document) { create :participatory_documents_document, :with_file, component: component }
    let!(:suggestion) { create(:participatory_documents_suggestion, :published, author: document.author, suggestable: document, answer: { en: answer }) }
    let!(:answer) { '<p>Safe answer text<img src="about:blank" onerror="alert(777)"></p>' }

    before do
      login_as document.author, scope: :user
      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
      find("#globalSuggestionTrigger").click
    end

    it "show sanitized answer" do
      expect(page).to have_content("Safe answer text")
      expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
    end
  end
end
