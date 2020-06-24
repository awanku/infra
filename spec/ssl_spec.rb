require 'openssl'

RSpec.describe "SSL" do
  context "certificate for awanku.id" do
    it "is valid for next 2 weeks" do
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.ssl_version = :TLSv1_2

      socket = TCPSocket.new("awanku.id", 443)
      ssl = OpenSSL::SSL::SSLSocket.new(socket, ctx)
      ssl.hostname = 'awanku.id'
      ssl.connect

      diff = ssl.peer_cert.not_after - Time.now.utc
      diff_days = diff / (60 * 60 * 24)
      expect(diff_days).to be > 14
    end
  end
end
