# frozen_string_literal: true

class RenameParticipatoryDocumentsValuationAssignmentReferences < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  def up
    # rubocop:disable Rails/SkipsModelValidations
    ActionLog.where(resource_type: "Decidim::ParticipatoryDocuments::ValuationAssignment").update_all(resource_type: "Decidim::ParticipatoryDocuments::EvaluationAssignment")
    Version.where(item_type: "Decidim::ParticipatoryDocuments::ValuationAssignment").update_all(item_type: "Decidim::ParticipatoryDocuments::EvaluationAssignment")
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    ActionLog.where(resource_type: "Decidim::ParticipatoryDocuments::EvaluationAssignment").update_all(resource_type: "Decidim::ParticipatoryDocuments::ValuationAssignment")
    Version.where(item_type: "Decidim::ParticipatoryDocuments::EvaluationAssignment").update_all(item_type: "Decidim::ParticipatoryDocuments::ValuationAssignment")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
