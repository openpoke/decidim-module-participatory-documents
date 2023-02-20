# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module ParticipatorySpaceUserRoleOverride
      extend ActiveSupport::Concern
      included do
        # there is a bug in decidim that does not clean records from ValuationAssignment when removing Space roles
        # This is a workaround to clean them manually
        # It might be possible that we need to change this when this is solved:
        # https://github.com/decidim/decidim/issues/10353
        has_many :suggestion_valuation_assignments,
                 class_name: "Decidim::ParticipatoryDocuments::ValuationAssignment",
                 foreign_key: :valuator_role_id,
                 dependent: :destroy
      end
    end
  end
end
