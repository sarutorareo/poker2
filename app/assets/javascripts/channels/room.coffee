App.room = App.cable.subscriptions.create {channel: "RoomChannel", room_id: $('#room_id').val(), user_id: $('#user_id').val()},
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log data
    if (data['type'] == "text_message")
      #console.log 'text_message: ' + data['message']
      $('#text_messages').append data['message']
      scroll_messages()
    else if (data['type'] == "entered_message")
      #console.log 'entered_message: ' + data['user_list']
      $('#entered_messages').html data['user_list']
#    else
#      assert('type not defined:'+ data['type'])

  speak: (room_id, user_id, message) ->
    @perform 'speak', {room_id: room_id, user_id: user_id, message: message}

$(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
  if event.keyCode is 13 # return = send
    App.room.speak $('#room_id').val(), $('#user_id').val(), event.target.value
    event.target.value = ''
    event.preventDefault()

$(document).on 'click', '#send_message', (event) ->
  App.room.speak $('#room_id').val(), $('#user_id').val(), $('#input_message').val()
  $('#input_message').val('')
  event.preventDefault()

### 以下はなぜ動かないのか
$('#send_message').click ->
  console.log 'test'
###
 
scroll_messages = ->
  # 一番下までスクロールする
  $('#text_messages').animate({scrollTop: $('#text_messages')[0].scrollHeight}, 'fast')

$ ->
  console.log 'test in document.ready'
  scroll_messages()
