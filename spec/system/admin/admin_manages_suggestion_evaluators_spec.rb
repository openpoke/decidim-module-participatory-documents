# frozen_string_literal: true

require "spec_helper"

describe "Admin manages suggestion evaluators" do
  let(:manifest_name) { "participatory_documents" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :admin_terms_accepted, :confirmed, organization:) }

  let(:component) { create(:participatory_documents_component, participatory_space: participatory_process) }
  let(:document) { create(:participatory_documents_document, :with_file, component:) }
  let(:section1) { create(:participatory_documents_section, document:) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }

  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end
  let(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }

  include Decidim::ComponentPathHelper

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

  context "when assigning to a evaluator" do
    it "shows the component select" do
      visit current_path

      within "tr", text: suggestion.id do
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

      within "tr", text: suggestion.id do
        expect(page).to have_css("td.evaluators-count", text: evaluator.name)
      end
    end
  end

  context "when filtering suggestions by assigned evaluator" do
    let!(:unassigned_suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }
    let!(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

    it "only shows the proposals assigned to the selected evaluator" do
      visit current_path
      expect(page).to have_content(assigned_suggestion.id)
      expect(page).to have_content(unassigned_suggestion.id)

      within ".filters__section" do
        click_on "Filter"
        find("a", text: "Assigned to evaluator").click
        find("a", text: evaluator.name).click
      end

      expect(page).to have_content(assigned_suggestion.id)
      expect(page).to have_no_content(unassigned_suggestion.id)
    end
  end

  context "when unassigning evaluators from the suggestion index page" do
    let(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

    it "shows the component select" do
      visit current_path

      within "tr", text: assigned_suggestion.id do
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

      within "tr", text: assigned_suggestion.id do
        expect(page).to have_css("td.evaluators-count", text: 0)
      end
    end
  end

  context "when unassigning evaluators from the suggestion show page" do
    let(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }

    it "can unassign a evaluator" do
      visit current_path
      within "tr", text: assigned_suggestion.id do
        click_on "Answer"
      end

      within "#evaluators" do
        expect(page).to have_content(evaluator.name)

        accept_confirm do
          find("svg use[href*='ri-close-circle-line']").click
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
      sign_in evaluator
      create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:)
      visit current_path
    end

    context "when the evaluator is assigned" do
      it "shows the evaluator is assigned" do
        expect(page).to have_no_css("tr", text: another_suggestion.id)
        within "tr", text: assigned_suggestion.id do
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

  context "when admin to assign a validator" do
    it "assigns the suggestions to the evaluator" do
      visit current_path
      within "tr", text: suggestion.id do
        click_on "Answer"
      end

      within "#js-form-assign-suggestion-to-evaluator" do
        tom_select("#evaluator_role_ids", option_id: evaluator_role.id)
      end

      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to an evaluator successfully")

      within "tr", text: suggestion.id do
        expect(page).to have_css("td.evaluators-count", text: evaluator.name)
      end
    end
  end

  context "when a evaluator manages assignments" do
    let(:evaluator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:evaluator_role2) { create(:participatory_process_user_role, role: :evaluator, user: evaluator2, participatory_process:) }
    let!(:assignment) { create(:suggestion_evaluation_assignment, suggestion:, evaluator_role:) }
    let(:suggestion_path) do
      Decidim::EngineRouter.admin_proxy(document.component).document_suggestion_path(document_id: document.id, id: suggestion.id)
    end

    before do
      switch_to_host(organization.host)
      login_as evaluator, scope: :user

      visit current_path
      within "tr", text: suggestion.id do
        click_on "Answer"
      end
      within "#js-form-assign-suggestion-to-evaluator" do
        tom_select("#evaluator_role_ids", option_id: evaluator_role2.id)
      end
    end

    it "assigns the suggestion to the evaluator" do
      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to an evaluator successfully")

      within "tr", text: suggestion.id do
        expect(page).to have_css("td.evaluators-count", text: "#{evaluator2.name} (+1)")
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
            find("svg use[href*='ri-close-circle-line']").click
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
