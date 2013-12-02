class ActiveDownload
  attr_accessor :path, :complete, :filesize, :started, :filename

  def initialize(path)
    @path            = path
    @filename        = File.basename(path)
    @incomplete_path = TVDownWeb::CONFIG[:incomplete_dir]
    @complete_path   = TVDownWeb::CONFIG[:complete_dir]

    if File.exist?("#{@incomplete_path}/#{@filename}") || File.exist?("#{@complete_path}/#{@filename}")
      raise ActiveDownload::FileExistsError
    elsif ActiveDownload.find(path)
      raise ActiveDownload::AlreadyDownloadingException
    else
      start_download!
    end
  end

  def start_download!
    Thread.new do
      begin
        ActiveDownload.downloads << self
        TVDownWeb::FTP.ftp do |ftp|
          self.started  = Time.now
          self.filesize = ftp.size(@path)
          self.complete = 0

          ftp.getbinaryfile(@path, "#{@incomplete_path}/#{@filename}", 409600) do |data|
            self.complete += data.size
          end
        end

        FileUtils.mv(File.join(@incomplete_path, @filename), File.join(@complete_path, @filename))
        ActiveDownload.downloads.delete(self)
      rescue Exception => e
        STDOUT.puts e
      end
    end
  end

  def percent_complete
    ((complete).to_f/filesize.to_f)*100
  end

  def speed(units = :KB)
    speed = (complete.to_f / (Time.now - started))
    if units == :KB
      speed / 1024
    elsif units == :MB
      speed / 1024 / 1024
    else
      speed
    end
  end

  def time_left
    begin
      time = (filesize.to_i - complete.to_i) / speed(:bytes).to_f
      hours = (time / 3600).to_i
      minutes = (time / 60.0 - hours.to_f * 60.0).to_i
      seconds = (time - (minutes.to_f * 60.0 + hours.to_f * 3600.0)).to_i
      "%02d:%02d:%02d" % [hours, minutes, seconds]
    rescue
      "00:00:00"
    end
  end

  class << self
    attr_accessor :downloads

    def downloads
      @downloads ||= []
    end

    def find(path)
      downloads.select { |dl| dl.path == path }.first
    end
  end

  class FileExistsError < Exception; end;
  class AlreadyDownloadingException < Exception; end;
end