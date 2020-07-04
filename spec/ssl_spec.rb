require 'openssl'

RSpec.describe "SSL" do
  domains = ['awanku.id', 'awanku.xyz']
  domains.each do |domain|
    context "certificate for #{domain}" do
      it "is valid for next 2 weeks" do
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.ssl_version = :TLSv1_2

        socket = TCPSocket.new(domain, 443)
        ssl = OpenSSL::SSL::SSLSocket.new(socket, ctx)
        ssl.hostname = domain
        ssl.connect

        diff = ssl.peer_cert.not_after - Time.now.utc
        diff_days = diff / (60 * 60 * 24)
        expect(diff_days).to be > 14
      end
    end
  end
end
