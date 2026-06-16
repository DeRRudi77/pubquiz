module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # Team pages (teams#show) are public, so the socket may be anonymous.
      # current_user is identified when a host is signed in, but a nil user is
      # allowed: Turbo only lets a client subscribe to the server-signed stream
      # names rendered into its own page, so public sockets can't snoop others.
      self.current_user = env["warden"]&.user
    end
  end
end
