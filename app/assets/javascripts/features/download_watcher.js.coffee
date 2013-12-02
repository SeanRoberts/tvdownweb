class APP.features.DownloadWatcher
  constructor: ->
    @$container = $('#downloads tbody')
    @template_path = 'templates/download'
    if @$container.length > 0
      @_loadDownloads()
      setInterval(@_loadDownloads, 5000)

  _loadDownloads: =>
    $.getJSON('/downloads.json', @_drawDownloads)

  _drawDownloads: (downloads) =>
    @$container.html('')
    for download in downloads
      template = JST['templates/download'](download: download)
      $(template).appendTo(@$container)