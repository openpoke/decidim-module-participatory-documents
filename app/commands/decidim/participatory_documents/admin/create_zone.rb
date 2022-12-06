# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateZone < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              create_zone
            end
            broadcast(:ok, zone)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :document, :zone

        def create_zone
          @zone = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Zone,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            title: form.title,
            description: form.description,
            uid: form.uid
          }.merge(document: document)
        end
      end
    end
  end
end
