# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This is the engine that runs on the public interface of decidim-ParticipatoryDocuments.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryDocuments

      routes do
        resources :documents do
          collection do
            get :pdf_viewer
          end
          resources :sections, only: [:show, :index] do
            resources :suggestions, except: [:show, :index, :destroy]
          end
        end

        root to: "documents#index"
      end

      config.to_prepare do
        Decidim.participatory_space_manifests.each do |manifest|
          manifest.model_class_name.constantize.new.user_roles.model.include(Decidim::ParticipatoryDocuments::ParticipatorySpaceUserRoleOverride)
        end
      rescue StandardError => e
        Rails.logger.error("Error while trying to include Decidim::ReportingProposals::ParticipatorySpaceUserRoleOverride: #{e.message}")
      end

      initializer "decidim_participatory_documents.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryDocuments::Engine.root}/app/cells")
      end

      initializer "decidim_participatory_documents.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
