class DownloadsController < ApplicationController
  respond_to :json

  def index
    @downloads = ActiveDownload.downloads
  end

  def create
    ActiveDownload.new("/#{params[:path]}.#{params[:format]}")
    redirect_to root_path
  end

end
