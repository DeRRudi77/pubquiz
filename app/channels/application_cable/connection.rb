module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # All pages that open a cable connection (games#show, teams#show) sit behind
    # `authenticate_user!`, so an unauthenticated socket has no legitimate use.
    def find_verified_user
      env["warden"]&.user || reject_unauthorized_connection
    end
  end
end
