# frozen_string_literal: true

require "spec_helper"

describe "Managing reporting proposals component" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:participatory_documents_component, participatory_space: participatory_process, name: component_name) }
  let(:component_name) do
    {
      en: "Participatory PDF",
      ca: "PDF Participatiu",
      es: "PDF Participativo"
    }
  end
  let!(:user) { create(:user, :confirmed, :admin, organization:) }

  def edit_component_path(component)
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit edit_component_path(component)
  end

  it "Shows the settings page" do
    expect(page).to have_content("Edit component")
    expect(page).to have_field "component_name_en", with: "Participatory PDF"
  end
end
