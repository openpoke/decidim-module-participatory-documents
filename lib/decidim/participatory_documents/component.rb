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
    settings.attribute :allowed_content_types, type: :string, default: Decidim::ParticipatoryDocuments.content_type_allowlist.join(", ")
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
  end
end
