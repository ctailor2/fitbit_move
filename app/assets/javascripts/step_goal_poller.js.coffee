$ ->
  # Buttons
  button = $('.action-button')
  startButton = $('#start-button')
  stopButton = $('#stop-button')

  button.click (event) ->
    $(this).prop('disabled', true)
    button.not(this).prop('disabled', false)

