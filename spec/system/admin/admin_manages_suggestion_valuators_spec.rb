# frozen_string_literal: true

require "spec_helper"

describe "Admin manages suggestion valuators", type: :system do
  let(:manifest_name) { "participatory_documents" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }

  let(:component) { create :participatory_documents_component, participatory_space: participatory_process }
  let(:document) { create :participatory_documents_document, component: component }
  let(:section1) { create(:participatory_documents_section, document: document) }
  let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }

  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end
  let(:valuator) { create :user, :confirmed, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }

  include Decidim::ComponentPathHelper

  include_context "when managing a component as an admin"

  context "when listing suggestions" do
    let(:valuator2) { create :user, organization: organization }
    let(:valuator_role2) { create :participatory_process_user_role, role: :valuator, user: valuator2, participatory_process: participatory_process }

    let!(:assignment) { create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role }

    before do
      document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")
    end

    it "shows the valuator name" do
      visit current_path
      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
        expect(page).not_to have_content("(+1)")
      end
    end

    it "shows the valuator name and counter" do
      create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role2

      visit current_path
      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
        expect(page).to have_content("(+1)")
      end
    end
  end

  context "when assigning to a valuator" do
    before do
      document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")
      visit current_path

      within find("tr", text: suggestion.id) do
        page.first(".js-suggestion-list-check").set(true)
      end

      click_button "Actions"
      click_button "Assign to valuator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-assign-suggestions-to-valuator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_css("button#js-submit-assign-suggestion-to-valuator", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-assign-suggestions-to-valuator" do
          select valuator.name, from: :valuator_role_id
          page.find("button#js-submit-assign-suggestion-to-valuator").click
        end
      end

      it "assigns the proposals to the valuator" do
        expect(page).to have_content("Suggestions assigned to a valuator successfully")

        within find("tr", text: suggestion.id) do
          expect(page).to have_selector("td.valuators-count", text: valuator.name)
        end
      end
    end
  end

  context "when filtering suggestions by assigned valuator" do
    let!(:unassigned_suggestion) { create(:participatory_documents_suggestion, suggestable: section1) }
    let(:assigned_suggestion) { suggestion }

    before do
      document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")

      create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role

      visit current_path
    end

    it "only shows the proposals assigned to the selected valuator" do
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

  context "when unassigning valuators from a proposal from the suggestion index page" do
    let(:assigned_suggestion) { suggestion }

    before do
      document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")

      create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role

      visit current_path

      within find("tr", text: assigned_suggestion.id) do
        page.first(".js-suggestion-list-check").set(true)
      end

      click_button "Actions"
      click_button "Unassign from valuator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-unassign-suggestions-from-valuator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_css("button#js-submit-unassign-suggestions-from-valuator", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-unassign-suggestions-from-valuator" do
          select valuator.name, from: :valuator_role_id
          page.find("button#js-submit-unassign-suggestions-from-valuator").click
        end
      end

      it "unassigns the proposals to the valuator" do
        expect(page).to have_content("Valuator unassigned from suggestions successfully")

        within find("tr", text: assigned_suggestion.id) do
          expect(page).to have_selector("td.valuators-count", text: 0)
        end
      end
    end
  end

  context "when unassigning valuators from a proposal from the suggestion show page" do
    let(:assigned_suggestion) { suggestion }

    before do
      document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")

      create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role

      visit current_path
      within find("tr", text: assigned_suggestion.id) do
        click_link "Answer"
      end
    end

    it "can unassign a valuator" do
      within "#valuators" do
        expect(page).to have_content(valuator.name)

        accept_confirm do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Valuator unassigned from suggestions successfully")

      expect(page).to have_no_selector("#valuators")
    end
  end

  context "when admin to assign a validator" do
    before do
      document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")

      visit current_path
      within find("tr", text: suggestion.id) do
        click_link "Answer"
      end

      within "#js-form-assign-suggestion-to-valuator" do
        find("#valuator_role_id").click
        find("option", text: valuator.name).click
      end

      click_button "Assign"
    end

    it "assigns the suggestions to the valuator" do
      expect(page).to have_content("Suggestions assigned to a valuator successfully")

      within find("tr", text: suggestion.id) do
        expect(page).to have_selector("td.valuators-count", text: valuator.name)
      end
    end
  end

  context "when a valuator manages assignments" do
    let(:valuator2) { create :user, organization: organization }
    let!(:valuator_role2) { create :participatory_process_user_role, role: :valuator, user: valuator2, participatory_process: participatory_process }

    before do
      switch_to_host(organization.host)
      login_as valuator, scope: :user

      create :suggestion_valuation_assignment, suggestion: suggestion, valuator_role: valuator_role

      document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")

      visit current_path
      within find("tr", text: suggestion.id) do
        click_link "Answer"
      end
    end

    context "when a valuator assigns other valuators" do
      before do
        within "#js-form-assign-suggestion-to-valuator" do
          find("#valuator_role_id").click
          find("option", text: valuator2.name).click
        end
      end

      it "assigns the suggestion to the valuator" do
        click_button "Assign"

        expect(page).to have_content("Suggestions assigned to a valuator successfully")

        within find("tr", text: suggestion.id) do
          expect(page).to have_selector("td.valuators-count", text: "#{valuator.name} (+1)")
        end
      end

      it "can remove only himself from the evaluators" do
        accept_confirm do
          within find("#valuators li", text: valuator.name) do
            find("a.red-icon").click
          end
        end

        expect(page).to have_content("Valuator unassigned from suggestions successfully")

        # within find("#valuators") do
        expect(page).not_to have_selector("#valuators")
        # end
      end
    end
  end
end
