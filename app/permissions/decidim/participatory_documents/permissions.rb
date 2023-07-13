# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        allow! if permission_action.subject == :suggestion && permission_action.action == :create

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::ParticipatoryDocuments::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        permission_action
      end
    end
  end
end
