# frozen_string_literal: true

require "spec_helper"

describe "Admin sees the action logs on homepage", type: :system do
  let(:organization) { component.organization }
  let(:component) { create(:participatory_documents_component) }
  let(:current_user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as current_user, scope: :user
  end

  context "when sees document related logs" do
    let(:file) do
      Rack::Test::UploadedFile.new(
        Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf"),
        "application/pdf"
      )
    end

    let(:form) do
      double(
        invalid?: false,
        title: { en: "Title test Section" },
        description: { en: "Description test Section" },
        box_color: "#f00f00",
        box_opacity: "50",
        current_user: current_user,
        file: file,
        current_component: component
      )
    end

    context "when is created" do
      let(:command) { Decidim::ParticipatoryDocuments::Admin::CreateDocument.new(form) }

      it "saves the created log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("created a document named")
      end
    end

    context "when is updated" do
      let(:document) { create(:participatory_documents_document) }

      let(:command) { Decidim::ParticipatoryDocuments::Admin::UpdateDocument.new(form, document) }

      it "saves the created log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("updated a document named")
      end
    end
  end

  context "when sees annotation related logs" do
    let(:document) { create(:participatory_documents_document, component: component) }

    context "when is created" do
      let(:form) do
        double(
          invalid?: false,
          page_number: 1,
          rect: [50, 50, 100, 100],
          id: "annotationid",
          group: "groupid",
          current_user: current_user
        )
      end

      let(:command) { Decidim::ParticipatoryDocuments::Admin::CreateAnnotation.new(form, document) }

      it "saves the created log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("created a new participatory area for")
      end
    end

    context "when is updated" do
      let(:command) { Decidim::ParticipatoryDocuments::Admin::UpdateAnnotation.new(form, document) }
      let(:section) { create(:participatory_documents_section, document: document) }

      let(:annotation) { create(:participatory_documents_annotation, section: section) }

      let(:form) do
        double(
          invalid?: false,
          page_number: 1,
          rect: [50, 50, 100, 100],
          id: annotation.id,
          group: "groupid",
          current_user: current_user
        )
      end

      it "saves the updated log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("has updated a participatory area for")
      end
    end

    context "when is deleted" do
      let(:command) { Decidim::ParticipatoryDocuments::Admin::DestroyAnnotation.new(form, document) }
      let(:section) { create(:participatory_documents_section, document: document) }

      let!(:annotation) { create(:participatory_documents_annotation, section: section) }

      let(:form) do
        double(
          invalid?: false,
          id: annotation.id,
          current_user: current_user
        )
      end

      it "saves the delete log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("deleted a participatory area for")
      end
    end
  end

  context "when sees section related logs" do
    let(:document) { create(:participatory_documents_document, component: component) }

    context "when is created" do
      let(:form) do
        double(
          invalid?: false,
          title: { en: "Title test Section" },
          current_user: current_user
        )
      end

      let(:command) { Decidim::ParticipatoryDocuments::Admin::CreateSection.new(form, document) }

      it "saves the created log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("has created a new Section named")
      end
    end

    context "when is updated" do
      let(:command) { Decidim::ParticipatoryDocuments::Admin::UpdateSection.new(form, document) }
      let!(:section) { create(:participatory_documents_section, document: document) }

      let(:form) do
        double(
          invalid?: false,
          title: { en: "Title test Section" },
          id: section.id,
          current_user: current_user
        )
      end

      it "saves the updated log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("has updated a section in")
      end
    end

    context "when is deleted" do
      let(:command) { Decidim::ParticipatoryDocuments::Admin::DestroySection.new(form, document) }
      let!(:section) { create(:participatory_documents_section, document: document) }

      let(:form) do
        double(
          invalid?: false,
          id: section.id,
          current_user: current_user
        )
      end

      it "saves the delete log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("has deleted a section")
      end
    end
  end

  context "when sees suggestion note related logs" do
    let(:document) { create(:participatory_documents_document, component: component) }
    let!(:suggestion) { create(:participatory_documents_suggestion, suggestable: document) }

    context "when is created" do
      let(:form) do
        double(
          invalid?: false,
          body: { en: "Title test Section" },
          suggestion: suggestion.id,
          current_user: current_user
        )
      end

      let(:command) { Decidim::ParticipatoryDocuments::Admin::CreateSuggestionNote.new(form, suggestion) }

      it "saves the created log" do
        expect { command.call }.to broadcast(:ok)
        visit decidim_admin.root_path

        expect(page).to have_content("created a new suggestion note")
      end
    end
  end
end
