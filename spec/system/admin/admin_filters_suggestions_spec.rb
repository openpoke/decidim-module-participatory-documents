# frozen_string_literal: true

require "spec_helper"

describe "Admin filters suggestions" do
  let(:organization) { component.organization }
  let(:model_name) { Decidim::ParticipatoryDocuments::Suggestion.model_name }
  let(:resource_controller) { Decidim::ParticipatoryDocuments::Admin::SuggestionsController }
  let(:participatory_process) { component.participatory_space }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:component) { create(:participatory_documents_component) }
  let!(:document) { create(:participatory_documents_document, author: user, component:) }
  let(:router) { Decidim::EngineRouter.admin_proxy(component).decidim_admin_participatory_process_participatory_documents }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit router.document_suggestions_path(document)
  end

  include_context "with filterable context"

  STATES = Decidim::ParticipatoryDocuments::Suggestion::POSSIBLE_STATES.map(&:to_sym)

  def create_suggestion_with_trait(trait)
    create(:participatory_documents_suggestion, state: trait, suggestable: document)
  end

  def suggestion_with_state(state)
    Decidim::ParticipatoryDocuments::Suggestion.where(suggestable: document).find_by(state:)
  end

  def suggestion_without_state(state)
    Decidim::ParticipatoryDocuments::Suggestion.where(suggestable: document).where.not(state:).last
  end

  context "when filtering by state" do
    let!(:suggestions) { STATES.map { |state| create_suggestion_with_trait(state) } }

    before { visit router.document_suggestions_path(document) }

    STATES.each do |state|
      context "when filtering suggestions by state: #{state}" do
        it_behaves_like "a filtered collection", options: "State", filter: I18n.t(state, scope: "decidim.admin.filters.suggestions.state_eq.values") do
          let(:in_filter) { translated(suggestion_with_state(state).body).first(40) }
          let(:not_in_filter) { translated(suggestion_without_state(state).body).first(40) }
        end
      end
    end
  end

  context "when suggestions are assigned to an evaluator with a filter applied" do
    let!(:document) { create(:participatory_documents_document, :with_file, author: user, component:) }
    let(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }
    let!(:evaluating_suggestion) { create(:participatory_documents_suggestion, :evaluating, suggestable: document, body: { en: "Evaluating suggestion" }) }
    let!(:accepted_suggestion) { create(:participatory_documents_suggestion, :accepted, suggestable: document, body: { en: "Accepted suggestion" }) }

    before { visit router.document_suggestions_path(document) }

    it "keeps the filter after the assignment" do
      apply_filter("State", "Evaluating")

      within "tr[data-id='#{evaluating_suggestion.id}']" do
        page.first(".js-suggestion-list-check").set(true)
      end
      click_on "Actions"
      click_on "Assign to evaluator"
      within "#js-form-assign-suggestions-to-evaluator" do
        tom_select("#assign_evaluator_role_ids", option_id: [evaluator_role.id])
        click_on("Assign")
      end

      expect(page).to have_content("Suggestions assigned to an evaluator successfully")
      within ".table-list" do
        expect(page).to have_content("Evaluating suggestion")
        expect(page).to have_no_content("Accepted suggestion")
      end
    end
  end

  context "when filtering by section" do
    let(:section) { create(:participatory_documents_section, document:) }
    let!(:global_suggestion) { create(:participatory_documents_suggestion, suggestable: document) }
    let!(:section_suggestion) { create(:participatory_documents_suggestion, suggestable: section) }

    before { visit router.document_suggestions_path(document) }

    it_behaves_like "a filtered collection", options: "Section", filter: "Global" do
      let(:in_filter) { translated(global_suggestion.body).first(40) }
      let(:not_in_filter) { translated(section_suggestion.body).first(40) }
    end
  end

  context "when searching by body" do
    let!(:suggestion2) { create(:participatory_documents_suggestion, suggestable: document) }
    let(:suggestion2_body) { translated(suggestion2.body) }

    before { visit router.document_suggestions_path(document) }

    it "can be searched by body" do
      search_by_text(suggestion2_body.split.first(2).join(" "))

      within ".table-list" do
        expect(page).to have_content(suggestion2_body.first(40))
      end
    end
  end
end
