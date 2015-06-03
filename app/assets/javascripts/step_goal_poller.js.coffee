$ ->
  # Buttons
  # ----------------------------------------------------------------------------
  button      = $('.action-button')
  startButton = $('#start-button')
  stopButton  = $('#stop-button')

  # Form Fields
  # ----------------------------------------------------------------------------
  pollingIntervalField = $('#polling_interval')
  endTimeField         = $('#end_time')
  stepGoalField        = $('#step_goal')
  formFields           = [pollingIntervalField, endTimeField, stepGoalField]

  # Data Views
  # ----------------------------------------------------------------------------
  stepCount = $('#step-count')

  # Utility Functions
  # ----------------------------------------------------------------------------
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

  getDateTimeDifference = (startDateTime, endDateTime) ->
    endDateTime - startDateTime

  millisToMinutes = (millis) ->
    millis / 1000 / 60

  minutesToMillis = (minutes) ->
    minutes * 60 * 1000

  disableField = (field) ->
    field.prop('disabled', true)

  enableField = (field) ->
    field.prop('disabled', false)

  # Domain Functions
  # ----------------------------------------------------------------------------
  formValid = ->
    stepGoal = parseInt(stepGoalField.val())
    stepGoalFieldValid = stepGoal >= 1000
    # TODO: This validation doesn't really make sense. A better one would be
    # that the step goal needs to be greater than the starting # of steps

    endDateTime = getDateTime(endTimeField.val())
    currentDateTime = new Date()
    timeFieldValid = endDateTime >= currentDateTime

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
    stepsPerMinWalking = 100
    endDateTime = getDateTime(endTimeField.val())
    stepGoal = parseInt(stepGoalField.val())
    currentDateTime = new Date()

    timeRangeMinutes = millisToMinutes(getDateTimeDifference(window.startDateTime, endDateTime))
    stepGap = stepGoal - window.startingSteps
    targetStepsPerMin = stepGap / timeRangeMinutes

    minutesFromStart = millisToMinutes(getDateTimeDifference(window.startDateTime, currentDateTime))
    currentStepTarget = window.startingSteps + (minutesFromStart * targetStepsPerMin)
    stepGapToTarget = currentStepTarget - stepCount

    minutesToWalk = Math.ceil(stepGapToTarget / stepsPerMinWalking)
    if minutesToWalk > 0
      alert('Take a walk for ' + minutesToWalk + ' minutes')

    # TODO: Also what happens if you need to walk for longer than the polling interval?

  getAndCheckSteps = ->
    getStepCount(checkAgainstStepGoal)
    managePolling()

  getAndCheckFinalSteps = ->
    stopButton.click()
    getStepCount(checkAgainstStepGoal)
    # TODO: Maybe this should return a message that's different from the usual?

  managePolling = ->
    endDateTime = getDateTime(endTimeField.val())
    currentDateTime = new Date()
    pollingIntervalMillis = minutesToMillis(parseInt(pollingIntervalField.val()))
    millisUntilEnd = getDateTimeDifference(currentDateTime, endDateTime)

    if millisUntilEnd < pollingIntervalMillis
      clearInterval(window.intervalID)
      window.intervalID = setTimeout(getAndCheckFinalSteps, millisUntilEnd)

  # Event Listeners
  # ----------------------------------------------------------------------------
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
      frequency = parseInt(pollingIntervalField.val()) * 60 * 1000
      getAndSetStartTime()
      getAndSetStartingSteps()
      window.intervalID = setInterval(getAndCheckSteps, frequency)
      managePolling()

  #*Stop Polling
  stopButton.click (event) ->
    clearInterval(window.intervalID)

