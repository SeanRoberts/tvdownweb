class Show
  attr_accessor :filename, :mtime, :dir, :size
  def initialize(ftp_list_output, dir)
    @filename = ftp_list_output.basename
    @mtime = ftp_list_output.mtime
    @dir = dir
    @size = ftp_list_output.size
  end

  def path
    File.join(dir, filename)
  end

  def self.all
    shows = []
    TVDownWeb::FTP.ftp do |ftp|
      TVDownWeb::CONFIG[:remote_dirs].each do |dir|
        ftp.list(dir) do |e|
          entry = Net::FTP::List.parse(e)
          if entry.file? && File.extname(entry.basename) != '.processed'
            shows << Show.new(entry, dir)
          end
        end
      end
    end

    shows.sort_by {|s| s.mtime}.reverse
  end
end