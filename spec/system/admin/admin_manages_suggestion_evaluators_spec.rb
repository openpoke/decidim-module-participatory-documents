# frozen_string_literal: true

require "spec_helper"

describe "Admin manages suggestion evaluators" do
  let(:manifest_name) { "participatory_documents" }
  let(:document) { create(:participatory_documents_document, :with_file, component:) }
  let(:section1) { create(:participatory_documents_section, document:) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }
  let(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }

  include_context "when managing a component as an admin"

  context "when listing suggestions" do
    let(:evaluator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:evaluator_role2) { create(:participatory_process_user_role, role: :evaluator, user: evaluator2, participatory_process:) }

    it "shows the evaluator name" do
      create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:)

      visit current_path
      within(".evaluators-count") do
        expect(page).to have_content(evaluator.name)
        expect(page).to have_no_content("(+1)")
      end
    end

    it "shows the evaluator name and counter" do
      create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:)
      create(:suggestion_evaluation_assignment, suggestion:, evaluator_role: evaluator_role2)

      visit current_path
      within(".evaluators-count") do
        expect(page).to have_content(evaluator2.name)
        expect(page).to have_content("(+1)")
      end
    end
  end

  context "when assigning to an evaluator" do
    it "assigns the suggestions to the evaluator" do
      visit current_path

      within "tr[data-id='#{suggestion.id}']" do
        page.first(".js-suggestion-list-check").set(true)
      end

      click_on "Actions"
      click_on "Assign to evaluator"
      expect(page).to have_css("#js-form-assign-suggestions-to-evaluator select", count: 1)
      expect(page).to have_button("Assign", count: 1)

      within "#js-form-assign-suggestions-to-evaluator" do
        tom_select("#assign_evaluator_role_ids", option_id: [evaluator_role.id])
        click_on("Assign")
      end

      expect(page).to have_content("Suggestions assigned to an evaluator successfully")

      within "tr[data-id='#{suggestion.id}']" do
        expect(page).to have_css("td.evaluators-count", text: evaluator.name)
      end
    end
  end

  context "when filtering suggestions by assigned evaluator" do
    let!(:unassigned_suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }
    let(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

    it "only shows the suggestions assigned to the selected evaluator" do
      visit current_path
      within ".table-list" do
        expect(page).to have_content(translated(assigned_suggestion.body).first(40))
        expect(page).to have_content(translated(unassigned_suggestion.body).first(40))
      end

      within ".filters__section" do
        click_on "Filter"
        find("a", text: "Assigned to evaluator").click
        find("a", text: evaluator.name).click
      end

      within ".table-list" do
        expect(page).to have_content(translated(assigned_suggestion.body).first(40))
        expect(page).to have_no_content(translated(unassigned_suggestion.body).first(40))
      end
    end
  end

  context "when unassigning evaluators from the suggestion index page" do
    let(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

    it "unassigns the suggestions from the evaluator" do
      visit current_path

      within "tr[data-id='#{assigned_suggestion.id}']" do
        page.first(".js-suggestion-list-check").set(true)
      end

      click_on "Actions"
      click_on "Unassign from evaluator"
      expect(page).to have_css("#js-form-unassign-suggestions-from-evaluator select", count: 1)
      expect(page).to have_button("Unassign", count: 1)

      within "#js-form-unassign-suggestions-from-evaluator" do
        tom_select("#unassign_evaluator_role_ids", option_id: [evaluator_role.id])
        click_on("Unassign")
      end
      expect(page).to have_content("Evaluator unassigned from suggestions successfully")

      within "tr[data-id='#{assigned_suggestion.id}']" do
        expect(page).to have_css("td.evaluators-count", text: 0)
      end
    end
  end

  context "when unassigning evaluators from the suggestion show page" do
    let(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

    it "can unassign an evaluator" do
      visit current_path
      within "tr[data-id='#{assigned_suggestion.id}']" do
        click_on "Answer"
      end

      within "#evaluators" do
        expect(page).to have_content(evaluator.name)

        accept_confirm do
          find("a.close-icon").click
        end
      end

      expect(page).to have_content("Evaluator unassigned from suggestions successfully")

      expect(page).to have_no_selector("#evaluators")
    end
  end

  context "when evaluators assign another evaluator" do
    let(:assigned_suggestion) { suggestion }
    let(:another_evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:another_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: another_evaluator, participatory_process:) }
    let!(:another_suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }

    before do
      create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:)

      relogin_as evaluator, scope: :user
      visit current_path
    end

    context "when the evaluator is assigned" do
      it "shows the evaluator is assigned" do
        expect(page).to have_no_content(translated(another_suggestion.body).first(40))
        within "tr[data-id='#{assigned_suggestion.id}']" do
          click_on "Answer"
        end

        within "#js-form-assign-suggestion-to-evaluator" do
          tom_select("#evaluator_role_ids", option_id: another_evaluator_role.id)
        end

        click_on "Assign"
        expect(page).to have_content("Suggestions assigned to an evaluator successfully")
      end
    end
  end

  context "when an admin assigns an evaluator" do
    it "assigns the suggestions to the evaluator" do
      visit current_path
      within "tr[data-id='#{suggestion.id}']" do
        click_on "Answer"
      end

      within "#js-form-assign-suggestion-to-evaluator" do
        tom_select("#evaluator_role_ids", option_id: evaluator_role.id)
      end

      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to an evaluator successfully")

      within "tr[data-id='#{suggestion.id}']" do
        expect(page).to have_css("td.evaluators-count", text: evaluator.name)
      end
    end
  end

  context "when an administrator of the space assigns an evaluator" do
    let(:space_admin) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:space_admin_role) { create(:participatory_process_user_role, role: :admin, user: space_admin, participatory_process:) }

    before do
      relogin_as space_admin, scope: :user
      visit current_path
    end

    it "assigns the suggestion to the evaluator from the page of the suggestion" do
      within "tr[data-id='#{suggestion.id}']" do
        click_on "Answer"
      end

      within "#js-form-assign-suggestion-to-evaluator" do
        tom_select("#evaluator_role_ids", option_id: evaluator_role.id)
      end

      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to an evaluator successfully")

      within "tr[data-id='#{suggestion.id}']" do
        expect(page).to have_css("td.evaluators-count", text: evaluator.name)
      end
    end
  end

  context "when an evaluator selects a suggestion with an unpublished answer" do
    let!(:suggestion) { create(:participatory_documents_suggestion, :accepted, :draft, suggestable: section1, answer: { en: "Foo bar" }) }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

    before do
      relogin_as evaluator, scope: :user
      visit current_path
    end

    it "does not offer to publish the answers" do
      within "tr[data-id='#{suggestion.id}']" do
        page.first(".js-suggestion-list-check").set(true)
      end
      click_on "Actions"

      expect(page).to have_button("Assign to evaluator")
      expect(page).to have_no_button("Publish answers")
    end
  end

  context "when an evaluator manages assignments" do
    let(:evaluator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:evaluator_role2) { create(:participatory_process_user_role, role: :evaluator, user: evaluator2, participatory_process:) }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }
    let(:suggestion_path) { Decidim::EngineRouter.admin_proxy(document.component).document_suggestion_path(document_id: document.id, id: suggestion.id) }

    before do
      relogin_as evaluator, scope: :user

      visit current_path
      within "tr[data-id='#{suggestion.id}']" do
        click_on "Answer"
      end
      within "#js-form-assign-suggestion-to-evaluator" do
        tom_select("#evaluator_role_ids", option_id: evaluator_role2.id)
      end
    end

    it "assigns the suggestion to the evaluator" do
      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to an evaluator successfully")

      within "tr[data-id='#{suggestion.id}']" do
        expect(page).to have_css("td.evaluators-count", text: "#{evaluator2.name} (+1)")
      end
    end

    it "can only remove their own assignment" do
      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to an evaluator successfully")

      visit suggestion_path
      within "#evaluators li", text: evaluator.name do
        expect(page).to have_link("Remove assignment")
      end
      within "#evaluators li", text: evaluator2.name do
        expect(page).to have_no_link("Remove assignment")
      end
    end

    context "when the evaluator is removed" do
      it "shows the evaluator is unassigned successfully" do
        click_on "Assign"
        expect(page).to have_content("Suggestions assigned to an evaluator successfully")

        visit suggestion_path
        expect(page).to have_css("#evaluators li", text: evaluator.name)

        accept_confirm do
          within "#evaluators li", text: evaluator.name do
            find("a.close-icon").click
          end
        end
        expect(page).to have_content("Evaluator unassigned from suggestions successfully")
        expect(page).to have_no_selector("#evaluators")

        expect(page).to have_no_content(translated(suggestion.body).first(20))

        visit suggestion_path
        expect(page).to have_content("You are not authorized to perform this action")
      end
    end
  end
end
