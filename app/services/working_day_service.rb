class WorkingDayService
  BANK_HOLIDAY_URL = 'https://www.gov.uk/bank-holidays.json'.freeze
  class << self
    def call(days)
      chosen_date = DateTime.current
      days_increased = 0
      bank_holidays = retrieve_bank_holiday_list
      while days_increased < days
        chosen_date = chosen_date.next_weekday
        days_increased += 1 unless chosen_date.to_date.in?(bank_holidays)
      end

      chosen_date
    end

    def retrieve_bank_holiday_list
      response = HTTParty.get('https://www.gov.uk/bank-holidays.json')
      response['england-and-wales']['events'].map { _1['date'].to_date }
    end
  end
end
