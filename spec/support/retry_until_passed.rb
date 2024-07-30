module RetryUntilPassed
  def retry_until_passed(attempts = 10)
    failed = 0
    loop do
      yield

      break
    rescue StandardError
      failed += 1
      raise if failed > attempts

      sleep(0.1) # Wait for the anchor jump to happen
    end
  end
end

RSpec.configuration.include RetryUntilPassed
