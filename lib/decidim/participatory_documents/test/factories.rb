# frozen_string_literal: true

FactoryBot.define do
  sequence(:pdf_uid) do |n|
    "randomstring-#{n}"
  end

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
    uid { generate(:pdf_uid) }

    trait :with_annotation do
      after :create do |section|
        section.annotations = [create(:participatory_documents_annotation, section: section)]
      end
    end

    trait :with_annotations do
      after :create do |section|
        section.annotations = create_list(:participatory_documents_annotation, 2, section: section)
      end
    end
  end

  factory :participatory_documents_annotation, class: "Decidim::ParticipatoryDocuments::Annotation" do
    section { create(:participatory_documents_section) }
    page_number { 1 }
    uid { generate(:pdf_uid) }

    after(:build) do |annotation|
      top = rand(1.0..60.0)
      left = rand(1.0..100.0)

      annotation.rect = { top: top, left: left, width: 15.9411, height: 18.0857 }
    end
  end

  factory :participatory_documents_suggestion, class: "Decidim::ParticipatoryDocuments::Suggestion" do
    suggestable { build(:dummy_resource) }
    author { build(:user, organization: suggestable.organization) }
    body { Decidim::Faker::Localized.localized { Faker::Lorem.paragraphs(number: 3).join(" ") } }
    state { Decidim::ParticipatoryDocuments::Suggestion::POSSIBLE_STATES.sample }
    answer { {} }

    trait :draft do
      answered_at { nil }
      answer_is_published { false }
    end

    trait :published do
      answered_at { Time.zone.now }
      answer_is_published { true }
    end

    trait :not_answered do
      state { :not_answered }
    end

    trait :evaluating do
      state { :evaluating }
      answered_at { Time.zone.now }
      answer_is_published { true }
    end

    trait :withdrawn do
      state { :withdrawn }
    end

    trait :rejected do
      state { :rejected }
      answered_at { Time.zone.now }
      answer_is_published { true }
    end

    trait :accepted do
      state { :accepted }
      answered_at { Time.zone.now }
    end
  end

  factory :suggestion_valuation_assignment, class: "Decidim::ParticipatoryDocuments::ValuationAssignment" do
    suggestion { build(:participatory_documents_suggestion) }
    valuator_role do
      space = suggestion.component.participatory_space
      organization = space.organization
      build :participatory_process_user_role, role: :valuator, user: build(:user, organization: organization)
    end
  end

  factory :participatory_documents_suggestion_note, class: "Decidim::ParticipatoryDocuments::SuggestionNote" do
    body { Faker::Lorem.sentences(number: 3).join("\n") }
    suggestion { build(:participatory_documents_suggestion) }
    author { build(:user, organization: suggestion.organization) }
  end
end
