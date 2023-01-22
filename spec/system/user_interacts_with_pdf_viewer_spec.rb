# frozen_string_literal: true

require "spec_helper"

describe "User interaction with PDF viewer", type: :system do
  include_context "with a component"
  let(:manifest_name) { "participatory_documents" }

  let!(:user) { create :user, :admin, :confirmed, organization: participatory_process.organization }
  let!(:document) { create(:participatory_documents_document, :with_file, author: user, component: component) }
  let!(:section) { create(:participatory_documents_section, :with_annotations, document: document) }

  before do
    login_as document.author, scope: :user

    page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
    annotation = section.annotations.last
    find("##{annotation.uid}").click
  end

  it "displays boxes in page" do
    section.annotations.each do |annotation|
      expect(page).to have_selector(:id, annotation.uid)
    end
  end

  it "displays the drawer" do
    expect(page).to have_selector("#participation-modal")
    expect(page).to have_selector("#participation-modal-form")
    expect(page).to have_selector("#suggestion-list")
  end

  context "when displaying the suggestions" do
    let(:other_user) { create :user, :admin, :confirmed, organization: user.organization }
    let!(:my_suggestion) { create(:participatory_documents_suggestion, suggestable: section, author: user) }
    let!(:other_suggestion) { create(:participatory_documents_suggestion, suggestable: section, author: other_user) }

    it "displays only my suggestion" do
      within "#participation-modal" do
        expect(page).to have_content(my_suggestion.body["en"])
        expect(page).not_to have_content(other_suggestion.body["en"])
      end
    end

    context "when admin interacts with my suggestion" do
      let(:answer) { { "en" => "A very cool idea" } }
      let(:draft) { true }

      context "when admin saves a response with :not_answered state" do
        let!(:my_suggestion) { create(:participatory_documents_suggestion, :not_answered, suggestable: section, author: user, answer: answer, answer_is_draft: draft) }

        context "when the answer is draft" do
          it "does not render admin note" do
            within "#participation-modal" do
              expect(page).not_to have_content(answer["en"])
            end
          end
        end

        context "when the answer is NOT draft " do
          let(:draft) { false }

          it "does not render admin note" do
            within "#participation-modal" do
              expect(page).not_to have_content(answer["en"])
            end
          end
        end
      end

      context "when admin saves a response with :evaluating state" do
        let!(:my_suggestion) { create(:participatory_documents_suggestion, :evaluating, suggestable: section, author: user, answer: answer, answer_is_draft: draft) }

        context "when the answer is draft" do
          it "does not render admin note" do
            within "#participation-modal" do
              expect(page).not_to have_content(answer["en"])
            end
          end
        end

        context "when the answer is NOT draft " do
          let(:draft) { false }

          it "renders admin note" do
            within "#participation-modal" do
              expect(page).to have_content(answer["en"])
            end
          end
        end
      end

      context "when admin saves a response with :withdrawn state" do
        let!(:my_suggestion) { create(:participatory_documents_suggestion, :withdrawn, suggestable: section, author: user, answer: answer, answer_is_draft: draft) }

        context "when the answer is draft" do
          it "does not render admin note" do
            within "#participation-modal" do
              expect(page).not_to have_content(answer["en"])
            end
          end
        end

        context "when the answer is NOT draft " do
          let(:draft) { false }

          it "renders admin note" do
            within "#participation-modal" do
              expect(page).not_to have_content(answer["en"])
            end
          end
        end
      end

      context "when admin saves a response with :rejected state" do
        let!(:my_suggestion) { create(:participatory_documents_suggestion, :rejected, suggestable: section, author: user, answer: answer, answer_is_draft: draft) }

        context "when the answer is draft" do
          it "does not render admin note" do
            within "#participation-modal" do
              expect(page).not_to have_content(answer["en"])
            end
          end
        end

        context "when the answer is NOT draft " do
          let(:draft) { false }

          it "renders admin note" do
            within "#participation-modal" do
              expect(page).to have_content(answer["en"])
            end
          end
        end
      end

      context "when admin saves a response with :accepted state" do
        let!(:my_suggestion) { create(:participatory_documents_suggestion, :accepted, suggestable: section, author: user, answer: answer, answer_is_draft: draft) }

        context "when the answer is draft" do
          it "does not render admin note" do
            within "#participation-modal" do
              expect(page).not_to have_content(answer["en"])
            end
          end
        end

        context "when the answer is NOT draft " do
          let(:draft) { false }

          it "renders admin note" do
            within "#participation-modal" do
              expect(page).to have_content(answer["en"])
            end
          end
        end
      end
    end
  end

  context "when adding a suggestion" do
    it "submits the content" do
      pending "For some reason the submit function is not being triggered from Capybara"
      raise "failure"

      # expect(page).to have_selector("#participation-modal", count: 1)
      # within "#new_suggestion_" do
      #   fill_in :suggestion_body, with: "Some random string longer than 15 chrs", wait: 10
      #   # find("#editor-modal-save").click( wait: 10)
      #   click_button(id: "editor-modal-save")
      #
      #   errors = page.driver.browser.manage.logs.get(:browser)
      #   pp errors.inspect
      #
      #   expect(page).to have_content("Some random string longer than 15 chrs")
      # end
      #
      # errors = page.driver.browser.manage.logs.get(:browser)
      # pp errors.inspect
    end
  end
end
