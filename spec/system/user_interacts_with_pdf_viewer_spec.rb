# frozen_string_literal: true

require "spec_helper"

describe "User interaction with PDF viewer", type: :system do
  include_context "with a component"
  let(:manifest_name) { "participatory_documents" }

  let!(:user) { create :user, :admin, :confirmed, organization: participatory_process.organization }
  let!(:document) { create(:participatory_documents_document, :with_file, author: user, component: component) }
  let!(:section) { create(:participatory_documents_section, :with_annotations, document: document) }

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
end
