require 'rails_helper'

RSpec.describe 'Reservations', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe 'searching' do
    before do
      Room.create!(code: '101', capacity: 2)
    end

    it 'allows users to search for available rooms with a given capacity in a period' do
      visit search_reservations_path

      expect(page).to have_content('New Reservation')

      fill_in 'From', with: '08/20/2020'
      fill_in 'To', with: '08/23/2020'
      select '2', from: '# of guests'
      click_on 'Search for Available Rooms'

      expect(page).to have_content('Available Rooms')

      within('table') do
        within('thead') do
          expect(page).to have_content('Code')
          expect(page).to have_content('Capacity')
          expect(page).to have_content('Actions')
        end

        within('tbody tr:first-child') do
          expect(page).to have_content('101')
          expect(page).to have_content('2 people')
          expect(page).to have_link('Create Reservation')
        end
      end
    end
  end
end
