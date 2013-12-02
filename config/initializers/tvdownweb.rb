class TVDownWeb
  CONFIG = YAML::load_file('config.yml').symbolize_keys
  FTP = ::FtpConnection.new(CONFIG[:ftp])
end