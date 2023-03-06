# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module ValuatorOverride
      extend ActiveSupport::Concern

      included do
        def accepted_components
          [:proposals, :participatory_documents]
        end
      end
    end
  end
end
