# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory documents", type: :system do
  let(:manifest_name) { "participatory_documents" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }

  def upload_file
    document.file.attach(io: File.open(Decidim::Dev.asset("Exampledocument.pdf")), filename: "Exampledocument.pdf")
  end

  include_context "when managing a component as an admin"

  context "when document is not created" do
    it "shows the upload button" do
      visit_component_admin

      expect(page).to have_content("Upload")
    end
  end

  context "when a file is not uploaded" do
    let!(:document) { create :participatory_documents_document, component: component }

    it "shows the upload button" do
      visit_component_admin

      expect(page).to have_content("Edit document")
    end
  end

  context "when a file is uploaded" do
    let!(:document) { create :participatory_documents_document, component: component }

    before do
      upload_file
    end

    it "shows the edit buttons" do
      visit_component_admin

      expect(page).to have_content("Edit file")
      expect(page).to have_content("Edit document")
    end
  end
end
