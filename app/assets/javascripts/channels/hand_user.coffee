App.hand_user_channel = App.cable.subscriptions.create {channel: "HandUserChannel", room_id: $('#room_id').val(), user_id: $('#user_id').val()},

  connected: ->
    # Called when the subscription is ready for use on the server
    console.log 'in hand_user.connected'

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log 'in hand_user.disconnected'

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log data
    if (data['type'] == "deal_cards")
      $('#user_hand').html data['DOM_cards']
    else
      alert('type not defined:'+ data['type'])
