App.room = App.cable.subscriptions.create {channel: "RoomChannel", room_id: $('#room_id').val(), user_id: $('#user_id').val()},

  connected: ->
    # Called when the subscription is ready for use on the server
    console.log 'in connected'
    @.pull_user_list $('#room_id').val()

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log 'in disconnected'

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log data
    if (data['type'] == "text_message")
      $('#text_message_table').append data['DOM_message']
      scroll_messages()
    else if (data['type'] == "msg_room_users")
      $('#room_users').html data['DOM_user_list']
    else
      alert('type not defined:'+ data['type'])

  speak: (room_id, user_id, message_content) ->
    @perform 'speak', {room_id: room_id, user_id: user_id, message_content: message_content}

  pull_user_list: (room_id) ->
    console.log 'pull_user_list room_id=' + room_id
    @perform 'pull_user_list', {room_id: room_id}

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

do_on_document_readay = ->
  console.log 'in do_on_document_readay!'
  scroll_messages()

$ ->
  do_on_document_readay()
