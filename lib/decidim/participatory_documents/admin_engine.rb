# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This is the engine that runs on the public interface of `ParticipatoryDocuments`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryDocuments::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :documents

        root to: "documents#index"
      end

      # initializer "decidim_reporting_proposals.admin_mount_routes" do
      #   Decidim::Core::Engine.routes do
      #     mount Decidim::ParticipatoryDocuments::AdminEngine, at: "/admin/participatory_documents", as: "decidim_admin_participatory_documents"
      #   end
      # end

      def load_seed
        nil
      end
    end
  end
end
