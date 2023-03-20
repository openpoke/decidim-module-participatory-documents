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
            resources :suggestion_notes, only: [:create]
          end
        end

        root to: "documents#index"
      end

      def load_seed
        nil
      end
    end
  end
end
