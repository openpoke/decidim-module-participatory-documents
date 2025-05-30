# frozen_string_literal: true

require "spec_helper"

describe "Admin manages suggestion valuators" do
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
  let(:valuator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:valuator_role) { create(:participatory_process_user_role, role: :valuator, user: valuator, participatory_process:) }

  include Decidim::ComponentPathHelper

  include_context "when managing a component as an admin"

  context "when listing suggestions" do
    let(:valuator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let(:valuator_role2) { create(:participatory_process_user_role, role: :valuator, user: valuator2, participatory_process:) }

    let!(:assignment) { create(:suggestion_valuation_assignment, suggestion:, valuator_role:) }

    it "shows the valuator name" do
      visit current_path
      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
        expect(page).to have_no_content("(+1)")
      end
    end

    it "shows the valuator name and counter" do
      create(:suggestion_valuation_assignment, suggestion:, valuator_role: valuator_role2)

      visit current_path
      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
        expect(page).to have_content("(+1)")
      end
    end
  end

  context "when assigning to a valuator" do
    it "shows the component select" do
      visit current_path

      within "tr", text: suggestion.id do
        page.first(".js-suggestion-list-check").set(true)
      end

      click_on "Actions"
      click_on "Assign to valuator"
      expect(page).to have_css("#js-form-assign-suggestions-to-valuator select", count: 1)
      expect(page).to have_button("Assign", count: 1)

      within "#js-form-assign-suggestions-to-valuator" do
        select valuator.name, from: :valuator_role_id
        click_on("Assign")
      end

      expect(page).to have_content("Suggestions assigned to a valuator successfully")

      within "tr", text: suggestion.id do
        expect(page).to have_css("td.valuators-count", text: valuator.name)
      end
    end
  end

  context "when filtering suggestions by assigned valuator" do
    let!(:unassigned_suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }
    let!(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_valuation_assignment, suggestion:, valuator_role:) }

    it "only shows the proposals assigned to the selected valuator" do
      visit current_path
      expect(page).to have_content(assigned_suggestion.id)
      expect(page).to have_content(unassigned_suggestion.id)

      within ".filters__section" do
        find("a.dropdown", text: "Filter").hover
        find("a", text: "Assigned to valuator").hover
        find("a", text: valuator.name).click
      end

      expect(page).to have_content(assigned_suggestion.id)
      expect(page).to have_no_content(unassigned_suggestion.id)
    end
  end

  context "when unassigning valuators from the suggestion index page" do
    let(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_valuation_assignment, suggestion:, valuator_role:) }

    it "shows the component select" do
      visit current_path

      within "tr", text: assigned_suggestion.id do
        page.first(".js-suggestion-list-check").set(true)
      end

      click_on "Actions"
      click_on "Unassign from valuator"
      expect(page).to have_css("#js-form-unassign-suggestions-from-valuator select", count: 1)
      expect(page).to have_button("Unassign", count: 1)

      within "#js-form-unassign-suggestions-from-valuator" do
        select valuator.name, from: :valuator_role_id
        click_on("Unassign")
      end
      expect(page).to have_content("Valuator unassigned from suggestions successfully")

      within "tr", text: assigned_suggestion.id do
        expect(page).to have_css("td.valuators-count", text: 0)
      end
    end
  end

  context "when unassigning valuators from the suggestion show page" do
    let(:assigned_suggestion) { suggestion }
    let!(:assignment) { create(:suggestion_valuation_assignment, suggestion:, valuator_role:) }

    it "can unassign a valuator" do
      visit current_path
      within "tr", text: assigned_suggestion.id do
        click_on "Answer"
      end

      within "#valuators" do
        expect(page).to have_content(valuator.name)

        accept_confirm do
          find("svg use[href*='ri-close-circle-line']").click
        end
      end

      expect(page).to have_content("Valuator unassigned from suggestions successfully")

      expect(page).to have_no_selector("#valuators")
    end
  end

  context "when valuators assign another valuator" do
    let(:assigned_suggestion) { suggestion }
    let(:another_valuator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:another_valuator_role) { create(:participatory_process_user_role, role: :valuator, user: another_valuator, participatory_process:) }
    let!(:another_suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }

    before do
      sign_in valuator
      create(:suggestion_valuation_assignment, suggestion:, valuator_role:)
      visit current_path
    end

    context "when the valuator is assigned" do
      it "shows the valuator is assigned" do
        expect(page).to have_no_css("tr", text: another_suggestion.id)
        within "tr", text: assigned_suggestion.id do
          click_on "Answer"
        end

        within "#js-form-assign-suggestion-to-valuator" do
          find_by_id("valuator_role_id").click
          find("option", text: another_valuator.name).click
        end

        click_on "Assign"
        expect(page).to have_content("Suggestions assigned to a valuator successfully")
      end
    end
  end

  context "when admin to assign a validator" do
    it "assigns the suggestions to the valuator" do
      visit current_path
      within "tr", text: suggestion.id do
        click_on "Answer"
      end

      within "#js-form-assign-suggestion-to-valuator" do
        find_by_id("valuator_role_id").click
        find("option", text: valuator.name).click
      end

      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to a valuator successfully")

      within "tr", text: suggestion.id do
        expect(page).to have_css("td.valuators-count", text: valuator.name)
      end
    end
  end

  context "when a valuator manages assignments" do
    let(:valuator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:valuator_role2) { create(:participatory_process_user_role, role: :valuator, user: valuator2, participatory_process:) }
    let!(:assignment) { create(:suggestion_valuation_assignment, suggestion:, valuator_role:) }
    let(:suggestion_path) do
      Decidim::EngineRouter.admin_proxy(document.component).document_suggestion_path(document_id: document.id, id: suggestion.id)
    end

    before do
      switch_to_host(organization.host)
      login_as valuator, scope: :user

      visit current_path
      within "tr", text: suggestion.id do
        click_on "Answer"
      end
      within "#js-form-assign-suggestion-to-valuator" do
        find_by_id("valuator_role_id").click
        find("option", text: valuator2.name).click
      end
    end

    it "assigns the suggestion to the valuator" do
      click_on "Assign"
      expect(page).to have_content("Suggestions assigned to a valuator successfully")

      within "tr", text: suggestion.id do
        expect(page).to have_css("td.valuators-count", text: "#{valuator.name} (+1)")
      end
    end

    context "when the valuator is removed" do
      it "shows the valuator is unassigned successfully" do
        accept_confirm do
          within "#valuators li", text: valuator.name do
            find("svg use[href*='ri-close-circle-line']").click
          end
        end
        expect(page).to have_content("Valuator unassigned from suggestions successfully")
        expect(page).to have_no_selector("#valuators")

        expect(page).to have_no_content(translated(suggestion.body).first(20))

        visit suggestion_path
        expect(page).to have_content("You are not authorized to perform this action")
      end
    end
  end
end
