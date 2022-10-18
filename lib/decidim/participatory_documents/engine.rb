# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This is the engine that runs on the public interface of decidim-ParticipatoryDocuments.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryDocuments

      routes do
        resources :participatory_documents

        root to: "participatory_documents#index"
      end

      initializer "decidim_participatory_documents.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
