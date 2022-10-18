# frozen_string_literal: true

require "spec_helper"

describe "Index participatory_documents", type: :system do
  include_context "with a component"
  let(:manifest_name) { "participatory_documents" }

  it "shows the index page" do
    visit_component

    expect(page).to have_content("Participatory document public placeholder")
  end
end
