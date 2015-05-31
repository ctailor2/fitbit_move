$ ->
  # Buttons
  button      = $('.action-button')
  startButton = $('#start-button')
  stopButton  = $('#stop-button')

  # Form Fields
  pollingIntervalField = $('#polling_interval')
  endTimeField         = $('#end_time')
  stepGoalField        = $('#step_goal')
  formFields           = [pollingIntervalField, endTimeField, stepGoalField]

  # Data Views
  stepCount = $('#step-count')

  # Utility Functions
  getDateTime = (timeString) ->
    return new Date(0) if timeString.length == 0
    hoursString = timeString.match(/^\d+/)[0]
    hours = parseInt(hoursString)
    minutesString = timeString.match(/\d+$/)[0]
    minutes = parseInt(minutesString)

    today = new Date()
    todayAtHours = new Date(today.setHours(hours))
    todayAtMinutes = new Date(todayAtHours.setMinutes(minutes))
    todatAtSeconds = new Date(todayAtMinutes.setSeconds(0))

  disableField = (field) ->
    field.prop('disabled', true)

  enableField = (field) ->
    field.prop('disabled', false)

  # Domain Functions
  formValid = ->
    stepGoal = stepGoalField.val()
    stepGoalFieldValid = stepGoal >= 1000

    endDateTime = getDateTime(endTimeField.val())
    currentDateTime = new Date()
    pollingIntervalMillis = pollingIntervalField.val() * 60 * 1000
    timeFieldValid = (endDateTime.getTime() - currentDateTime.getTime()) > pollingIntervalMillis

    stepGoalFieldValid && timeFieldValid

  getAndSetStartTime = ->
    window.startDateTime = new Date()

  getStepCount = (callback) ->
    $.ajax
      url: '/'
      type: 'GET'
      dataType: 'json'
      success: (data) ->
        currentStepCount = data.step_count
        stepCount.text(currentStepCount)
        if typeof callback == 'function'
          callback(currentStepCount)

  saveStartingSteps = (stepCount) ->
    window.startingSteps = stepCount

  getAndSetStartingSteps = ->
    getStepCount(saveStartingSteps)

  checkAgainstStepGoal = (stepCount) ->
    # TODO: build this out
    # EXAMPLE:
    # Interval is 30 min
    # 5:20pm goal is 7k steps
    # User presses start at 9am
    # Get current # of steps and store it as the starting # of steps - 3k steps
    # Get current time and store it as the start time - 9am
    # Calculate the number of minutes between the start time and end time - 500 minutes
    endDateTime = getDateTime(endTimeField.val())
    timeRangeMinutes = (endDateTime - window.startDateTime) / 1000 / 60
    # Calculate the number of steps between the starting # and the step goal - 4k steps
    stepGap = parseInt(stepGoalField.val()) - window.startingSteps
    # Calculate the number of steps needed per minute to meet the step goal - 8 steps/min
    targetStepsPerMin = stepGap / timeRangeMinutes
    # Poller wakes up in 30 min
    # Poller gets the current # of steps - 3100 steps
    # Poller gets the current time - 9:30am
    currentDateTime = new Date()
    # Poller calculates the number of minutes between the start time and current time - 30 minutes
    minutesFromStart = (currentDateTime - window.startDateTime) / 1000 / 60
    # Poller calculates the target # of steps at the current time - 3000 + (30 * 8) = 3240
    currentStepTarget = window.startingSteps + (minutesFromStart * targetStepsPerMin)
    # Poller calculates the number of steps needed to catch up to the target - 3240 - 3100 = 140
    stepGapToTarget = currentStepTarget - stepCount
    # Poller calculates the number of min of walking needed to catch up to the target - 140 / 100 = 1.4 ~> 2 minutes
    minutesToWalk = Math.ceil(stepGapToTarget / 100)
    # Alert the user that they need to walk for 2 minutes
    alert('Take a walk for ' + minutesToWalk + ' minutes')
    # TODO: Think about what happens if there isn't a complete interval of time left
    # between the last time the poller woke up and the end time

  getAndCheckSteps = ->
    getStepCount(checkAgainstStepGoal)

  # Event Listeners
  #*Toggle Buttons
  button.click (event) ->
    if formValid()
      $(this).prop('disabled', true)
      button.not(this).prop('disabled', false)

  #*Toggle Form Fields
  startButton.click (event) ->
    if formValid()
      $.each formFields, ->
        disableField(this)
  stopButton.click (event) ->
    $.each formFields, ->
      enableField(this)

  #*Start Polling
  startButton.click (event) ->
    if formValid()
      frequency = pollingIntervalField.val() * 60 * 1000
      getAndSetStartTime()
      getAndSetStartingSteps()
      window.intervalID = setInterval(getAndCheckSteps, frequency)

  #*Stop Polling
  stopButton.click (event) ->
    clearInterval(window.intervalID)

