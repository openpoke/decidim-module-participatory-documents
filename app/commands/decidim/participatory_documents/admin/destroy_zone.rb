# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class DestroyZone < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          # we do not really need to validate the form, since we are removing the object
          # return broadcast(:invalid, code: form.errors) if form.invalid? #
          # TODO: Add annotation constraint ?!
          # return broadcast(:invalid, code: 2) if zone.annotations.length > 1
          # TODO: ADD Comment existance validation
          # return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              destroy_zone
            end
            broadcast(:ok)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid, code: 3)
          end
        end

        private

        attr_reader :form, :document

        def destroy_zone
          Decidim.traceability.perform_action!(
            :delete,
            zone,
            current_user
          ) do
            zone.annotations.destroy_all
            zone.destroy!
          end
        end

        def zone
          @zone ||= document.zones.find_by!(uid: form.uid)
        end
      end
    end
  end
end
