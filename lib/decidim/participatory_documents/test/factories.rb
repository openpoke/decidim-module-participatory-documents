# frozen_string_literal: true

FactoryBot.define do
  factory :participatory_documents_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :participatory_documents).i18n_name }
    manifest_name { :participatory_documents }
  end

  factory :participatory_documents_document, class: "Decidim::ParticipatoryDocuments::Document" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    component { create(:participatory_documents_component) }
    author { build(:user, :confirmed, organization: component.organization) }

    trait :with_file do
      file { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
    end
  end

  factory :participatory_documents_section, class: "Decidim::ParticipatoryDocuments::Section" do
    document { create :participatory_documents_document }
  end

  factory :participatory_documents_annotation, class: "Decidim::ParticipatoryDocuments::Annotation" do
    section { create(:participatory_documents_section) }
    page_number { 1 }
    rect { [50, 50, 100, 100] }
    uid { "randomstring" }
  end
end
