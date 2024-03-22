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
    let!(:proposals) do
      STATES.map { |state| create_suggestion_with_trait(state) }
    end

    before { visit router.document_suggestions_path(document) }

    STATES.each do |state|
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.suggestions.state_eq.values")

      context "when filtering proposals by state: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
          let!(:in_filter) { translated(suggestion_with_state(state).body).first(40) }
          let!(:not_in_filter) { translated(suggestion_without_state(state).body).first(40) }
        end
      end
    end
  end

  context "when searching by ID or title" do
    let!(:suggestion2) { create(:participatory_documents_suggestion, suggestable: document) }
    let!(:suggestion2_body) { translated(suggestion2.body) }

    before { visit router.document_suggestions_path(document) }

    it "can be searched by title" do
      search_by_text(suggestion2_body.split.first(2).join(" "))

      expect(page).to have_content(suggestion2.id)
    end
  end

  it_behaves_like "paginating a collection" do
    # rubocop:disable RSpec/ExcessiveCreateList
    let!(:collection) { create_list(:participatory_documents_suggestion, 50, suggestable: document) }
    # rubocop:enable RSpec/ExcessiveCreateList
  end
end
