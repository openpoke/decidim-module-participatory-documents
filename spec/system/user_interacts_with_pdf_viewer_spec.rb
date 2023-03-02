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
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :not_answered, suggestable: sugested, author: user, answer: answer, answer_is_published: published) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is published " do
            let(:published) { true }

            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :evaluating state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :evaluating, suggestable: sugested, author: user, answer: answer, answer_is_published: published) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is published " do
            let(:published) { true }

            it "renders admin note" do
              within "#participation-modal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :withdrawn state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :withdrawn, suggestable: sugested, author: user, answer: answer, answer_is_published: published) }

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
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :rejected, suggestable: sugested, author: user, answer: answer, answer_is_published: published) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is NOT draft " do
            let(:published) { true }

            it "renders admin note" do
              within "#participation-modal" do
                expect(page).to have_content(answer["en"])
              end
            end
          end
        end

        context "when admin saves a response with :accepted state" do
          let!(:my_suggestion) { create(:participatory_documents_suggestion, :accepted, suggestable: sugested, author: user, answer: answer, answer_is_published: published) }

          context "when the answer is draft" do
            it "does not render admin note" do
              within "#participation-modal" do
                expect(page).not_to have_content(answer["en"])
              end
            end
          end

          context "when the answer is NOT draft " do
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
      find("##{annotation.uid}").click
    end

    it_behaves_like "interacts with drawer"

    it "displays boxes in page" do
      section.annotations.each do |annotation|
        expect(page).to have_selector(:id, annotation.uid)
      end
    end
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
    before do
      login_as document.author, scope: :user

      page.visit Decidim::EngineRouter.main_proxy(component).pdf_viewer_documents_path(file: document.attached_uploader(:file).path)
      annotation = section.annotations.last
      find("##{annotation.uid}").click
    end

    it "submits the content" do
      pending "There for some reason Capybara does not handle this"
      raise "Pending"
      # expect(page).to have_selector("#participation-modal", count: 1)
      # expect(page).to have_css("#participation-modal.active")
      # within "#new_suggestion_" do
      #   fill_in :suggestion_body, with: "Some random string longer than 15 chrs", wait: 10
      #   # click_button("Save", wait: 10)
      #
      #   expect(page).to have_content("Some random string longer than 15 chrs")
      # end
    end
  end
end
