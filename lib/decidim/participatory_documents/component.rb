# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:participatory_documents) do |component|
  component.engine = Decidim::ParticipatoryDocuments::Engine
  component.admin_engine = Decidim::ParticipatoryDocuments::AdminEngine
  component.icon = "media/images/participatory_documents.svg"

  component.on(:before_destroy) do |instance|
    raise "Can't destroy this component when there are ParticipatoryDocuments" if Decidim::ParticipatoryDocuments::Document.where(component: instance).any?
  end

  # component.data_portable_entities = ["Decidim::ParticipatoryDocuments::Document"]

  # component.newsletter_participant_entities = ["Decidim::ParticipatoryDocuments::Document"]

  # component.actions = %w(endorse vote create withdraw amend comment vote_comment)

  # component.query_type = "Decidim::ParticipatoryDocuments::ParticipatoryDocumentsType"

  component.permissions_class_name = "Decidim::ParticipatoryDocuments::Permissions"

  component.settings(:global) do |settings|
    settings.attribute :suggestion_answering_enabled, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
  end

  # component.register_resource(:participatory_document) do |resource|
  #   resource.model_class_name = "Decidim::ParticipatoryDocuments::Document"
  #   resource.template = "decidim/participatory_documents/documents/linked_participatory_documents"
  #   resource.card = "decidim/participatory_documents/participatory_document"
  #   resource.reported_content_cell = "decidim/participatory_documents/reported_content"
  #   resource.actions = %w(endorse vote amend comment vote_comment)
  #   resource.searchable = true
  # end

  # component.register_stat :participatory_documents_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
  # end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :participatory_documents).i18n_name,
      published_at: Time.current,
      manifest_name: :participatory_documents,
      participatory_space: participatory_space
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    params = {
      component: component,
      title: Decidim::Faker::Localized.sentence(word_count: 2),
      description: Decidim::Faker::Localized.sentence(word_count: 20),
      author: admin_user,
      file: ActiveStorage::Blob.create_after_upload!(
        io: File.open(File.join(__dir__, "seeds", "Exampledocument.pdf")),
        filename: "Exampledocument.pdf",
        content_type: "application/pdf",
        metadata: nil
      ) # Keep after attached_to
    }

    document = Decidim.traceability.create!(
      Decidim::ParticipatoryDocuments::Document,
      admin_user,
      params,
      visibility: "all"
    )

    group1 = Decidim.traceability.create!(
      Decidim::ParticipatoryDocuments::Section,
      admin_user,
      {
        document: document,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        state: :draft,
        uid: "group-1"
      },
      visibility: "admin-only"
    )
    group2 = Decidim.traceability.create!(
      Decidim::ParticipatoryDocuments::Section,
      admin_user,
      {
        document: document,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        state: :draft,
        uid: "group-2"
      },
      visibility: "admin-only"
    )
    group3 = Decidim.traceability.create!(
      Decidim::ParticipatoryDocuments::Section,
      admin_user,
      {
        document: document,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        state: :draft,
        uid: "group-3"
      },
      visibility: "admin-only"
    )

    annotations = [
      {
        uid: "box-1",
        page_number: 1,
        section: group1,
        rect: {
          "left": 25.5,
          "top": 22.123,
          "width": 30.1,
          "height": 10.2
        }
      },
      {
        uid: "box-2",
        page_number: 1,
        section: group2,
        rect: {
          "left": 5.5,
          "top": 2.123,
          "width": 10.1,
          "height": 10.2
        }
      },
      {
        uid: "box-3",
        page_number: 1,
        section: group2,
        rect: {
          "left": 15.5,
          "top": 12.123,
          "width": 10.1,
          "height": 10.2
        }
      },
      {
        uid: "box-4",
        page_number: 1,
        section: group3,
        rect: {
          "left": 75.5,
          "top": 82.123,
          "width": 10.1,
          "height": 10.2
        }
      },
      {
        uid: "box-5",
        page_number: 2,
        section: group3,
        rect: {
          "left": 15.5,
          "top": 12.123,
          "width": 10.1,
          "height": 10.2
        }
      }
    ]
    annotations.each do |annotation|
      Decidim.traceability.create!(
        Decidim::ParticipatoryDocuments::Annotation,
        admin_user,
        annotation,
        visibility: "admin-only"
      )
    end

    [document, group1, group2, group3].each do |suggestable|
      10.times do
        Decidim::ParticipatoryDocuments::Suggestion.create(
          body: Decidim::Faker::Localized.sentence(word_count: 20),
          suggestable: suggestable,
          author: admin_user,
          state: Decidim::ParticipatoryDocuments::Suggestion::POSSIBLE_STATES.sample
        )
      end
    end
  end
end
