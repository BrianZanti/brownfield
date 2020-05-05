class YoutubeService
  def video_info(id)
    params = { part: 'snippet,contentDetails,statistics', id: id }

    get_json('youtube/v3/videos', params)
  end

  def playlist_videos(playlist_id, page_token = nil)
    params = { part: 'snippet,contentDetails', playlistId: playlist_id, maxResults: 50}
    params[:pageToken] = page_token if page_token
    get_json('youtube/v3/playlistItems', params)
  end

  def playlist_info(playlist_id)
    params = { part: 'snippet', id: playlist_id }

    get_json('youtube/v3/playlists', params)
  end

  private

  def get_json(url, params)
    response = conn.get(url, params)

    JSON.parse(response.body, symbolize_names: true)
  end

  def conn
    Faraday.new(url: 'https://www.googleapis.com') do |f|
      f.adapter Faraday.default_adapter
      f.params[:key] = ENV['YOUTUBE_API_KEY']
    end
  end
end
