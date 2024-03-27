# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory documents" do
  include Decidim::TranslationsHelper
  let(:manifest_name) { "participatory_documents" }
  let(:router) { Decidim::EngineRouter.admin_proxy(document.component).decidim_admin_participatory_process_participatory_documents }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:participatory_documents_component, participatory_space: participatory_process) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:document) { create(:participatory_documents_document, component:) }

  let(:section1) { create(:participatory_documents_section, document:) }
  let(:section2) { create(:participatory_documents_section, document:) }
  let!(:single_document_suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
  let!(:document_suggestions) { create_list(:participatory_documents_suggestion, 9, suggestable: document) }
  let!(:section1_suggestions) { create_list(:participatory_documents_suggestion, 10, suggestable: section1) }
  let!(:section2_suggestions) { create_list(:participatory_documents_suggestion, 10, suggestable: section2) }
  let(:all_suggestions_count) { document.suggestions.count + section1_suggestions.count + section2_suggestions.count }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit router.document_suggestions_path(document)
  end

  context "when using bulk answer" do
    let!(:document_suggestions) do
      create_list(:participatory_documents_suggestion, 3, :accepted, :draft, body: { en: "Test suggestion" }, suggestable: document, answer: { en: "Foo bar" })
    end
    let!(:section1_suggestions) do
      create(:participatory_documents_suggestion, :accepted, :published,
             body: { en: "Test suggestion" }, suggestable: section1, answer: { en: "Foo bar" })
    end
    let!(:section2_suggestions) { nil }

    context "when publishing answers at once" do
      before do
        visit current_path
      end

      it "publishes some answers" do
        page.find("#suggestions_bulk.js-check-all").click
        page.first("[data-published-state=false] .js-suggestion-list-check").click

        click_link_or_button "Actions"
        click_link_or_button "Publish answers"

        within ".table-scroll" do
          expect(page).to have_content("No ", count: 3)
          expect(page).to have_content("Yes", count: 1)
        end

        within "#js-publish-answers-actions" do
          expect(page).to have_content("Answers for 2 suggestions will be published.")
        end
        click_link_or_button("Publish")
        20.times do
          # wait for the ajax call to finish
          sleep(1)
          expect(page).to have_content(I18n.t("suggestions.publish_answers.success", scope: "decidim.participatory_documents.admin"))
          break
        rescue StandardError
          # ignore and loop again if ajax content is still not there
          nil
        end
        expect(page).to have_content(I18n.t("suggestions.publish_answers.success", scope: "decidim.participatory_documents.admin"))

        visit current_path

        within ".table-scroll" do
          expect(page).to have_content("Yes", count: 3)
        end
      end

      it "can't publish answers for non answered suggestions" do
        page.find("#suggestions_bulk.js-check-all").click
        page.all("[data-published-state=false] .js-suggestion-list-check").map(&:click)

        click_link_or_button "Actions"
        expect(page).to have_no_content("Publish answers")
      end
    end
  end

  context "when sorting answered questions" do
    context "when sorting ascending" do
      let!(:document_suggestion) do
        create(:participatory_documents_suggestion, :published,
               state: :accepted, suggestable: document, answer: { en: "Foo bar" })
      end

      it "displays the right state" do
        visit router.document_suggestions_path(document)

        click_link_or_button("Published Answer")

        within(".table-list") do
          expect(page).to have_no_content(document_suggestion.body["en"].first(20))
        end
      end
    end

    context "when sorting descending" do
      let!(:document_suggestion) do
        create(:participatory_documents_suggestion, :published,
               state: :accepted, suggestable: document, answer: { en: "Foo bar" })
      end

      it "displays the right state" do
        visit router.document_suggestions_path(document)

        click_link_or_button("Published Answer")
        click_link_or_button("Published Answer")

        within(".table-list") do
          expect(page).to have_content(document_suggestion.body["en"].first(20))
        end
      end
    end
  end

  context "when asnwering suggestions" do
    let!(:document_suggestions) { nil }
    let!(:section1_suggestions) { nil }
    let!(:section2_suggestions) { nil }

    shared_examples "marks the answer by state" do |state:|
      context "when there is no answer" do
        let!(:document_suggestion) { create(:participatory_documents_suggestion, :draft, state:, suggestable: document) }

        it "displays the right state" do
          visit router.document_suggestions_path(document)

          within(".table-list") do
            expect(page).to have_content("-")
          end
        end
      end

      context "when not published" do
        let!(:document_suggestion) { create(:participatory_documents_suggestion, :draft, state:, suggestable: document, answer: { en: "Foo bar" }) }

        it "displays the right state" do
          visit router.document_suggestions_path(document)

          within(".table-list") do
            expect(page).to have_content("No")
          end
        end
      end

      context "when published" do
        let!(:document_suggestion) { create(:participatory_documents_suggestion, :published, state:, suggestable: document, answer: { en: "Foo bar" }) }

        it "displays the right state" do
          visit router.document_suggestions_path(document)

          within(".table-list") do
            expect(page).to have_content("Yes")
          end
        end
      end
    end

    context "when suggestion has an answer not published" do
      it_behaves_like "marks the answer by state", state: :not_answered
      it_behaves_like "marks the answer by state", state: :withdrawn
      it_behaves_like "marks the answer by state", state: :rejected
      it_behaves_like "marks the answer by state", state: :accepted
    end
  end

  it "displays the author's name" do
    expect(page).to have_content("List Suggestions")
    within(".table-list") do
      expect(page).to have_content("Author")
      document_suggestions.each do |suggestion|
        expect(page).to have_content(suggestion.author.name)
      end
    end
  end

  context "when admin to exports suggestions" do
    it "exports a JSON" do
      find(".exports.button").click
      perform_enqueued_jobs { click_link_or_button "Suggestions as JSON" }

      within ".flash.success" do
        expect(page).to have_content("in progress")
      end

      expect(last_email.subject).to include("suggestions", "json")
      expect(last_email.attachments.length).to be_positive
      expect(last_email.attachments.first.filename).to match(/^suggestions.*\.zip$/)

      attachment = last_email.attachments.first

      Zip::File.open_buffer(attachment.body.raw_source) do |zip_file|
        json_file_entry = zip_file.glob("*.json").first
        json_content = json_file_entry.get_input_stream.read
        json_data = JSON.parse(json_content)
        expect(json_data.length).to eq(all_suggestions_count)
      end
    end
  end

  context "when sorting by author's name" do
    let(:dummy_user) { create(:user, name: "zzz-user 1", organization:) }
    let!(:single_document_suggestion) { create(:participatory_documents_suggestion, suggestable: document, author: dummy_user) }

    it "sorts ascendent" do
      expect(page).to have_content(dummy_user.name)
      click_link_or_button "Author"
      expect(page).to have_no_content(dummy_user.name)
    end

    it "sorts descendent" do
      expect(page).to have_content(dummy_user.name)
      click_link_or_button "Author"
      click_link_or_button "Author"
      expect(page).to have_content(dummy_user.name)
    end
  end

  it "filters by author's name" do
    expect(page).to have_content(document_suggestions.first.author.name)
    expect(page).to have_content(document_suggestions.last.author.name)
    within ".filters__section" do
      find("a.dropdown", text: "Filter").hover
      find("a", text: "Author").hover
      find("a", text: document_suggestions.last.author.name).click
    end
    expect(page).to have_no_content(document_suggestions.first.author.name)
    expect(page).to have_content(document_suggestions.last.author.name)
  end

  context "when sorting by section's name" do
    let(:section1) { create(:participatory_documents_section, document:, title: { en: "zzzz-section" }) }

    it "sorts ascendent" do
      expect(page).to have_content(translated_attribute(section1.title))
      click_link_or_button "Section"
      expect(page).to have_no_content(translated_attribute(section1.title))
    end

    it "sorts descendent" do
      expect(page).to have_content(translated_attribute(section1.title))
      click_link_or_button "Section"
      click_link_or_button "Section"
      expect(page).to have_content(translated_attribute(section1.title))
    end
  end

  it "filters by section name" do
    within ".table-list" do
      expect(page).to have_content("Global")
      expect(page).to have_content(translated_attribute(section1.title))
    end
    within ".filters__section" do
      find("a.dropdown", text: "Filter").hover
      find("a", text: "Section").hover
      find("a", text: translated_attribute(section1.title)).click
    end
    within ".table-list" do
      expect(page).to have_no_content("Global")
      expect(page).to have_content(translated_attribute(section1.title))
    end
  end

  it "does not raise an error" do
    expect(page).to have_content("List Suggestions")
    within(".table-scroll") do
      expect(page).to have_content("Global")
      expect(page).to have_content(section1.title["en"])
      expect(page).to have_no_content(section2.title["en"])
    end
    within("nav[aria-label='Pagination']") do
      click_link_or_button("Next")
    end
    within(".table-scroll") do
      expect(page).to have_no_content("Global")
      expect(page).to have_content(section1.title["en"])
      expect(page).to have_content(section2.title["en"])
    end
  end

  context "when the global suggestion includes a file" do
    let!(:document_suggestion) do
      create(:participatory_documents_suggestion,
             suggestable: document,
             body: { en: "" },
             answer: { en: "This is a test answer" },
             file: attachment)
    end

    let(:attachment) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

    it "displays the file" do
      within(".table-scroll") do
        find("a.sort_link", text: "Id").click
        expect(page).to have_css("svg use[href*='ri-file-download-line']", count: 1)
      end
    end

    it "displays the file an the show page" do
      within(".table-scroll") do
        find("a.sort_link", text: "Id").click
        target_row = find("tr", text: document_suggestion.id.to_s)
        target_row.find("a.action-icon[title='Answer']").click
      end
      expect(page).to have_css("svg use[href*='ri-file-download-line']", count: 1)
    end
  end

  shared_examples "publish suggestion answers" do |selection:, published: false|
    before do
      within(".table-scroll") do
        find(".action-icon--show-suggestion", match: :first).click
      end
    end

    it "publishes some answers" do
      within "form.suggestion_form_admin" do
        choose selection
        fill_in_i18n_editor(
          :answer_suggestion_answer,
          "#answer_suggestion-answer-tabs",
          en: "This is my answer"
        )
        check :answer_suggestion_answer_is_published if published
      end
      click_link_or_button "Answer"
      expect(page).to have_content("Successfully")
    end
  end

  context "when answering suggestion" do
    context "when rejects the suggestion" do
      it_behaves_like "publish suggestion answers", selection: "Rejected"
      context "and being published" do
        it_behaves_like "publish suggestion answers", selection: "Rejected", published: true
      end
    end

    context "when accepts the suggestion" do
      it_behaves_like "publish suggestion answers", selection: "Accepted"
      context "and being published" do
        it_behaves_like "publish suggestion answers", selection: "Accepted", published: true
      end
    end

    context "when evaluate the suggestion" do
      it_behaves_like "publish suggestion answers", selection: "Evaluating"
      context "and being published" do
        it_behaves_like "publish suggestion answers", selection: "Evaluating", published: true
      end
    end

    context "when Not Answering the suggestion" do
      it_behaves_like "publish suggestion answers", selection: "Not Answered"
      context "and being published" do
        # it_behaves_like "publish suggestion answers", selection: "Not Answered", published: true
        it "publishes some answers" do
          within(".table-scroll") do
            find(".action-icon--show-suggestion", match: :first).click
          end
          within "form.suggestion_form_admin" do
            choose "Not Answered"
            fill_in_i18n_editor(
              :answer_suggestion_answer,
              "#answer_suggestion-answer-tabs",
              en: "This is my answer"
            )
          end
          check :answer_suggestion_answer_is_published
          click_link_or_button "Answer"
          expect(page).to have_no_content("Successfully added the answer")
          expect(page).to have_content(%q(It's not possible to publish with status "not answered"))
        end
      end
    end
  end
end
