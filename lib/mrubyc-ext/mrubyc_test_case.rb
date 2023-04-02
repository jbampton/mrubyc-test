class MrubycTestCase
  def initialize(information, verbose = true)
    @information = information
    $mock ||= Mock.new
    @puts_success_message = verbose
    @puts_failure_message = verbose
  end

  def success(assertion, expected, actual)
    $success_count += 1
    if @puts_success_message
      puts $colors[:success] + '  ' + actual.to_ss + " (:" + assertion.to_s + ")" + $colors[:reset]
    else
      print $colors[:success] + '.' + $colors[:reset]
    end
  end
  def failure(assertion, expected, actual, message, error = nil)
    $failures << {
      class_and_method: $current_class_and_method,
      path: @information[:path].to_s,
      line: @information[:line].to_s,
      description: @information[:description].to_s,
      message: message,
      assertion: assertion.to_s,
      expected: expected.to_ss,
      actual: actual.to_ss,
      error: error
    }
    if @puts_failure_message
      puts $colors[:failure] + '  ' + actual.to_ss + " (:" + assertion.to_s + ")" + $colors[:reset]
    else
      print $colors[:failure] + '.' + $colors[:reset]
    end
  end

  def pend
    $pendings << {
      class_and_method: $current_class_and_method,
      path: @information[:path].to_s,
      line: @information[:line].to_s,
    }
    print $colors[:pending] + '.' + $colors[:reset]
  end

  def assert_raise(*errors, &block)
    assertion = :assert_raise
    e = nil
    begin
      block.call
    rescue => e
      errors.each do |error|
        if error == e.class || (error.class == e.class && error.message == e.message)
          success(assertion, errors, error)
          return
        end
      end
    end
    expected = errors.map {|error|
      error.message.length > 0 ? "#<#{error.class}: #{error.message}>" : "#{error.class}"
    }.join(" || ")
    failure(assertion, expected, (e || "[No error]"), "")
  end

  def assert_equal(expected, actual, message = nil)
    assertion = :assert_equal
    actual == expected ? success(assertion, expected, actual) : failure(assertion, expected, actual, message)
  end

  def assert_not_equal(expected, actual, message = nil)
    assertion = :assert_not_equal
    actual != expected ? success(assertion, expected, actual) : failure(assertion, expected, actual, message)
  end

  def assert_nil(expression, message = nil)
    assertion = :assert_not_nil
    expression == nil ? success(assertion, nil, expression) : failure(assertion, "nil", expression, message)
  end

  def assert_not_nil(expression, message = nil)
    assertion = :assert_not_nil
    expression != nil ? success(assertion, nil, expression) : failure(assertion, "!nil", expression, message)
  end

  def assert(expression, message = nil)
    assertion = :assert
    expression ? success(assertion, nil, expression) : failure(assertion, "!nil && !false", expression, message)
  end

  def assert_true(expression, message = nil)
    assertion = :assert_true
    expression == true ? success(assertion, nil, expression) : failure(assertion, "true", expression, message)
  end

  def assert_false(expression, message = nil)
    assertion = :assert_false
    expression == false ? success(assertion, nil, expression) : failure(assertion, "false", expression, message)
  end

  def assert_in_delta(expected, actual, message = nil, delta = 0.001)
    assertion = :assert_in_delta
    dt = actual - expected
    if -delta <= dt && dt <= delta
      success(assertion, expected, actual)
    else
      failure(assertion, expected, actual, message)
    end
  end

  def self.description(text)
  end
  def self.desc(text)
  end
  def setup
  end
  def teardown
  end
  def stub(object)
    object
  end
  def check_mock
    $mock.expected.keys.each do |key|
      $mock.actual[key] = 0 unless $mock.actual[key]
      if $mock.expected[key] > $mock.actual[key]
        failure(:mock, $mock.expected[key], $mock.actual[key], key.to_s + ' should have been called at least expected times')
      else
        success(:mock, $mock.expected[key], $mock.actual[key])
      end
    end
  end
end
