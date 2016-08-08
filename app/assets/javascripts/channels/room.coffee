App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    $('#messages').append data['message']

  speak: (room_id, message) ->
    @perform 'speak', {room_id: room_id, message: message}

$(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
  if event.keyCode is 13 # return = send
    App.room.speak $('#room_id').val(), event.target.value
    event.target.value = ''
    event.preventDefault()

$(document).on 'click', '#send_message', (event) ->
  App.room.speak $('#room_id').val(), $('#input_message').val()
  $('#input_message').val('')
  event.preventDefault()

### 以下はなぜ動かないのか
$('#send_message').click ->
  console.log 'test'
###
 
