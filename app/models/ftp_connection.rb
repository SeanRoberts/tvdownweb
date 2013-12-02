require 'net/ftp'
require 'net/ftp/list'

class FtpConnection
  def initialize(opts = {})
    @opts = opts.symbolize_keys
  end

  def ftp(&block)
    Net::FTP.open(@opts[:server], @opts[:username], @opts[:password], &block);
  end
end