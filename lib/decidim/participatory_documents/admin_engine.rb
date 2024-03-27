# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This is the engine that runs on the public interface of `ParticipatoryDocuments`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryDocuments::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :documents do
          collection do
            get :pdf_viewer
            get :edit_pdf
          end
          member do
            put :publish
          end
          resources :annotations, except: [:show, :new, :edit]
          resources :sections, except: [:show, :index]
          resources :suggestions, only: [:index, :show] do
            resources :valuation_assignments, only: [:destroy]
            collection do
              post :publish_answers
              resource :valuation_assignment, only: [:create, :destroy]
            end

            member do
              patch :answer
            end
            resources :suggestion_notes, only: [:create, :edit, :update]
          end
        end

        root to: "documents#index"
      end

      initializer "decidim_decidim_participatory_documents.register_icons" do
        Decidim.icons.register(name: "stack-line", icon: "stack-line", category: "system", description: "", engine: :decidim_participatory_documents)
        Decidim.icons.register(name: "mail-check-line", icon: "mail-check-line", category: "system", description: "", engine: :decidim_participatory_documents)
        Decidim.icons.register(name: "question-answer-line", icon: "question-answer-line", category: "system", description: "", engine: :decidim_participatory_documents)
        Decidim.icons.register(name: "skip-back-line", icon: "skip-back-line", category: "system", description: "", engine: :decidim_participatory_documents)
      end

      def load_seed
        nil
      end
    end
  end
end
