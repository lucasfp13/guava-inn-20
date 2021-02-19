require 'rails_helper'

RSpec.describe 'Reservations', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe 'searching' do
    before do
      @room_101 = create_room(code: '101', capacity: 3)
      @room_102 = create_room(
        code: '102',
        capacity: 2,
        with_reservations: [{ start_date: '2020-07-30', end_date: '2020-08-05'}]
      )
    end

    context 'when there are none available rooms' do
      it 'show the standard system message' do
        visit new_search_reservations_path

        expect(page).to have_content('New Reservation')

        fill_in 'From', with: Date.new(2020, 7, 20)
        fill_in 'To', with: Date.new(2020, 8, 20)
        select '5', from: '# of guests'
        click_on 'Search for Available Rooms'

        expect(page).to have_content('Available Rooms')

        within('table') do
          within('thead') do
            expect(page).to have_content('Code')
            expect(page).to have_content('Capacity')
            expect(page).to have_content('Actions')
          end

          within('tbody') do
            expect(page).to have_no_content(@room_101.code)
            expect(page).to have_no_content(@room_102.code)
            expect(page).to have_content('There are no available rooms for the selected filters')
          end
        end
      end
    end

    context 'when user tries to search with start date after end date' do
      it 'shows no results and show an alert' do
        visit new_search_reservations_path

        expect(page).to have_content('New Reservation')

        fill_in 'From', with: Date.new(2020, 7, 20)
        fill_in 'To', with: Date.new(2020, 7, 18)
        select '5', from: '# of guests'
        click_on 'Search for Available Rooms'

        expect(page).to have_no_content('Available Rooms')
        expect(page).to have_no_content(@room_101.code)
        expect(page).to have_no_content(@room_102.code)

        expect(page).to have_content("Initial date should be before the end date.")
      end
    end

    it 'allow users to search for available rooms with a given capacity in a period' do
      visit new_search_reservations_path

      expect(page).to have_content('New Reservation')

      fill_in 'From', with: Date.new(2020, 7, 20)
      fill_in 'To', with: Date.new(2020, 8, 20)
      select '3', from: '# of guests'
      click_on 'Search for Available Rooms'

      expect(page).to have_content('Available Rooms')

      within('table') do
        within('thead') do
          expect(page).to have_content('Code')
          expect(page).to have_content('Capacity')
          expect(page).to have_content('Actions')
        end

        within('tbody tr:first-child') do
          expect(page).to have_no_content(@room_102.code)
          expect(page).to have_content(@room_101.code)
          expect(page).to have_content("#{@room_101.capacity} people")
          expect(page).to have_link('Create Reservation')
        end
      end
    end

    it 'allow users to go back to the rooms list' do
      visit new_search_reservations_path

      expect(page).to have_link('Back', href: root_path)
    end
  end

  describe 'new reservation' do
    before do
      @room_101 = create_room(
        code: '101',
        capacity: 5,
        with_reservations: [{ start_date: '2020-07-30', end_date: '2020-08-05'}]
      )
    end

    it 'allows users to create a new reservation' do
      visit new_search_reservations_path

      fill_in 'From', with: Date.new(2020, 7, 20)
      fill_in 'To', with: Date.new(2020, 7, 30)
      select '3', from: '# of guests'
      click_on 'Search for Available Rooms'

      search_request = "#{URI.parse(current_url).path}?#{URI.parse(current_url).query}"

      within('table') do
        within('thead') do
          expect(page).to have_content('Code')
          expect(page).to have_content('Capacity')
          expect(page).to have_content('Actions')
        end

        within('tbody tr:first-child') do
          click_link 'Create Reservation'
        end
      end

      expect(page).to have_content("New Reservation")
      expect(page).to have_selector('input[value="2020-07-20"]')
      expect(page).to have_selector('input[value="2020-07-30"]')
      expect(page).to have_selector('select option[selected][value="3"]')

      fill_in 'Guest name', with: 'Fulano Teste'
      click_on 'Create Reservation'

      expect(page).to have_content("Room #{@room_101.code}")
      expect(page).to have_content('was successfully created.')
      expect(page).to have_content('2020-07-20 to 2020-07-30')
    end

    context 'when user tries to create a reservation with invalid values' do
      it 'shows an alert with specific validation errors' do
        visit new_search_reservations_path

        fill_in 'From', with: Date.new(2020, 7, 20)
        fill_in 'To', with: Date.new(2020, 7, 30)
        select '3', from: '# of guests'
        click_on 'Search for Available Rooms'

        search_request = "#{URI.parse(current_url).path}?#{URI.parse(current_url).query}"

        within('table') do
          within('thead') do
            expect(page).to have_content('Code')
            expect(page).to have_content('Capacity')
            expect(page).to have_content('Actions')
          end

          within('tbody tr:first-child') do
            click_on 'Create Reservation'
          end
        end
        
        fill_in 'Start date', with: Date.new(2020, 7, 31)
        fill_in 'End date', with: Date.new(2020, 7, 30)
        select '7', from: 'Number of guests'
        click_on 'Create Reservation'

        expect(page).to have_content("Guest name can't be blank")
        expect(page).to have_content('The start date should be before the end date')
        expect(page).to have_content("Number of guests shouldn't be greater than room capacity")
      end
    end
  end
end
