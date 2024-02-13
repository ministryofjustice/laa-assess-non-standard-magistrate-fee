class Event
  class ChangeRisk < Event
    def title_options
      { risk: details['to'] }
    end
  end
end
