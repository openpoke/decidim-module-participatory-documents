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
    title { generate_localized_title }
  end

  factory :participatory_documents_annotation, class: "Decidim::ParticipatoryDocuments::Annotation" do
    section { create(:participatory_documents_section) }
    page_number { 1 }
    rect { [50, 50, 100, 100] }
    uid { "randomstring" }
  end

  factory :participatory_documents_suggestion, class: "Decidim::ParticipatoryDocuments::Suggestion" do
    suggestable { build(:dummy_resource) }
    author { build(:user, organization: suggestable.organization) }
    body { Decidim::Faker::Localized.localized { Faker::Lorem.paragraphs(number: 3).join("\n") } }
    state { Decidim::ParticipatoryDocuments::Suggestion::POSSIBLE_STATES.sample }

    trait :not_answered do
      state { :not_answered }
    end
    trait :evaluating do
      state { :evaluating }
    end
  end
end
