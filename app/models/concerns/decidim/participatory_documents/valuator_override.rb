# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module ValuatorOverride
      extend ActiveSupport::Concern

      included do
        # it is important to ensure that the aliased method name is unique in case of other modules are doing the same
        alias_method :decidim_participatory_documents_original_accepted_components, :accepted_components

        def accepted_components
          decidim_participatory_documents_original_accepted_components + [:participatory_documents]
        end
      end
    end
  end
end
