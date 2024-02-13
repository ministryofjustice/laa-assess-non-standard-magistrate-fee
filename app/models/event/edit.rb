class Event
  class Edit < Event
    def historical?
      false
    end
  end
end
