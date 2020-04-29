class Admin::TutorialImportController < ApplicationController
  def new
    @tutorial = Tutorial.new
  end

  def create
    service = YoutubeService.new

    playlist_id = playlist_params[:playlist_id]
    playlist_info = service.playlist_info(playlist_id)
    tutorial_data = {
      playlist_id: playlist_id,
      title: playlist_info[:items].first[:snippet][:title],
      description: playlist_info[:items].first[:snippet][:description],
      thumbnail: playlist_info[:items].first[:snippet][:thumbnails][:high][:url]
    }
    tutorial = Tutorial.create!(tutorial_data)
    playlist_videos = service.playlist_videos(playlist_id)
    add_videos_to_tutorial(tutorial, playlist_videos)
    while playlist_videos[:nextPageToken]
      playlist_videos = service.playlist_videos(playlist_id, playlist_videos[:nextPageToken])
      add_videos_to_tutorial(tutorial, playlist_videos)
    end
    link = view_context.link_to('View it here.', tutorial_path(tutorial))
    flash[:success] = "Successfully created tutorial. #{link}"
    redirect_to admin_dashboard_path
  end

  def add_videos_to_tutorial(tutorial, playlist_videos)
    playlist_videos[:items].each do |video|
      video_data = {
        title: video[:snippet][:title],
        description: video[:snippet][:description],
        video_id: video[:snippet][:resourceId][:videoId],
        thumbnail: video[:snippet][:thumbnails][:high][:url],
        position: video[:snippet][:position]
      }
      tutorial.videos.create!(video_data)
    end
  end

  private

  def playlist_params
    params.require(:tutorial).permit(:playlist_id)
  end
end
