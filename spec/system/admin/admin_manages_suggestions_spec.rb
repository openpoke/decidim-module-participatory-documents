# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory documents", type: :system do
  let(:manifest_name) { "participatory_documents" }
  let(:router) { Decidim::EngineRouter.admin_proxy(document.component).decidim_admin_participatory_process_participatory_documents }

  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) { create :participatory_documents_component, participatory_space: participatory_process }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:document) { create :participatory_documents_document, component: component }

  let(:section1) { create(:participatory_documents_section, document: document) }
  let(:section2) { create(:participatory_documents_section, document: document) }
  let!(:document_suggestions) { create_list(:participatory_documents_suggestion, 10, suggestable: document) }
  let!(:section1_suggestions) { create_list(:participatory_documents_suggestion, 10, suggestable: section1) }
  let!(:section2_suggestions) { create_list(:participatory_documents_suggestion, 10, suggestable: section2) }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit router.document_suggestions_path(document)
  end

  it "does not raise an error" do
    expect(page).to have_content("List Suggestions")
    within(".table-scroll") do
      expect(page).to have_content("Global")
      expect(page).to have_content(section1.title["en"])
      expect(page).not_to have_content(section2.title["en"])
    end
    within(".pagination") do
      find(".pagination-next > a").click
    end
    within(".table-scroll") do
      expect(page).not_to have_content("Global")
      expect(page).to have_content(section1.title["en"])
      expect(page).to have_content(section2.title["en"])
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
        fill_in_i18n(
          :answer_suggestion_answer,
          "#answer_suggestion-answer-tabs",
          en: "This is my answer"
        )
        check :answer_suggestion_answer_is_published if published
        click_button "Answer"
      end
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
            fill_in_i18n(
              :answer_suggestion_answer,
              "#answer_suggestion-answer-tabs",
              en: "This is my answer"
            )
            check :answer_suggestion_answer_is_published
            click_button "Answer"
          end
          expect(page).not_to have_content("Successfully added the answer")
          expect(page).to have_content(%q(It's not possible to publish with status "not answered"))
        end
      end
    end
  end
end
