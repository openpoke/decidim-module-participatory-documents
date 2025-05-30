# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This is the engine that runs on the public interface of decidim-ParticipatoryDocuments.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryDocuments

      routes do
        scope path: "documents/:document_id/sections/:section_id" do
          resources :suggestions, only: [:index, :create], controller: :section_suggestions, as: :document_section_suggestions
        end
        resources :documents do
          collection do
            get :pdf_viewer
          end
          resources :suggestions, only: [:index, :create], controller: :document_suggestions do
            collection do
              post :export
            end
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

      # Older versions of Rack does not support the .mjs extension, so we register it here.
      initializer "decidim_participatory_documents.rack_mime" do
        Mime::Type.register "text/javascript", :mjs
        Rack::Mime::MIME_TYPES[".mjs"] = "text/javascript"
      end

      initializer "decidim_participatory_documents.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          Decidim::ParticipatorySpaceRoleConfig::Valuator.include(Decidim::ParticipatoryDocuments::ValuatorOverride)
        end
      end

      initializer "decidim_participatory_documents.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryDocuments::Engine.root}/app/cells")
      end

      initializer "decidim_participatory_documents.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_decidim_participatory_documents.register_icons" do
        Decidim.icons.register(name: "checkbox-multiple-line", icon: "checkbox-multiple-line", category: "system", description: "", engine: :decidim_participatory_documents)
        Decidim.icons.register(name: "file-download-line", icon: "file-download-line", category: "system", description: "", engine: :decidim_participatory_documents)
      end
    end
  end
end
