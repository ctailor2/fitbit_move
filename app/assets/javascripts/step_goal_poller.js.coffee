$ ->
  # Buttons
  button      = $('.action-button')
  startButton = $('#start-button')
  stopButton  = $('#stop-button')

  # Form Fields
  pollingIntervalField = $('#polling_interval')
  startTimeField       = $('#start_time')
  endTimeField         = $('#end_time')
  stepGoalField        = $('#step_goal')
  formFields           = [pollingIntervalField, startTimeField, endTimeField, stepGoalField]

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

  disableField = (field) ->
    field.prop('disabled', true)

  enableField = (field) ->
    field.prop('disabled', false)

  # Domain Functions
  formValid = ->
    stepGoalFieldValid = stepGoalField.val() >= 1000

    endDateTime = getDateTime(endTimeField.val())
    startDateTime = getDateTime(startTimeField.val())
    timeFieldsValid = endDateTime >= startDateTime

    stepGoalFieldValid && timeFieldsValid

  pollAgainstStepGoal = ->
    $.ajax
      url: '/'
      type: 'GET'
      dataType: 'json'
      success: (data) ->
        currentStepCount = data.step_count
        stepCount.text(currentStepCount)
        # TODO: uncomment the below line
        #checkAgainstStepGoal(currentStepCount)

  checkAgainstStepGoal = (stepCount) ->
    # TODO: build this out

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
      # TODO: change the below to a setInterval after done testing
      window.intervalID = setTimeout(pollAgainstStepGoal, 3000)

  #*Stop Polling
  stopButton.click (event) ->
    clearInterval(window.intervalID)

