require 'rails_helper'

RSpec.describe 'Admin Importing Playlists' do
  it 'imports a playlist and all of its videos' do
    admin = User.create!(email: 'admin@example.com', first_name: 'Bossy', last_name: 'McBosserton', password:  "password", role: :admin)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

    visit '/admin/tutorials/new'

    click_link 'Import YouTube Playlist'

    playlist_id = 'PLopY4n17t8RBuyIohlCY9G8sbyXrdEJls'

    fill_in :tutorial_playlist_id, with: playlist_id

    click_button 'Import Playlist'

    expect(page).to have_content('Successfully created tutorial. View it here.')

    click_link 'View it here.'

    new_tutorial = Tutorial.last

    expect(current_path).to eq("/tutorials/#{new_tutorial.id}")

    within '#videos' do
      expect(page).to have_css('.video', count: 69)
      within first('.video') do
        expect(page).to have_content("Deadpool's Chimichangas")
      end
      within all('.video')[1] do
        expect(page).to have_content("Ice Cream Sandwiches")
      end
      within all('.video').last do
        expect(page).to have_content("Essential Kitchen Tools")
      end
    end
  end
end
