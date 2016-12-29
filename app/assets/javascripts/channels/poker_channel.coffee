ACT_KBN_FOLD = 0
ACT_KBN_CALL = 1
ACT_KBN_RAISE = 2
ACT_KBN_CALL_ALL_IN = 3
ACT_KBN_RAISE_ALL_IN = 4

App.poker = App.cable.subscriptions.create {channel: "PokerChannel", room_id: $('#room_id').val(), user_id: $('#user_id').val()},

  connected: ->
    # Called when the subscription is ready for use on the server
    console.log 'in connected poker_channel'

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log 'in disconnected poker_channel'

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log data
    if (data['type'] == "msg_hand_users")
      $('#hand_users').html data['DOM_hand_user_list']
      $('#round_rules').html data['DOM_round_rules']
    else if (data['type'] == "msg_update_betting_round")
      $('#betting_round').html data['DOM_betting_round']
    else if (data['type'] == "msg_update_board")
      $('#board').html data['DOM_board']
    else
      alert('type not defined:'+ data['type'])


  start_hand: (room_id, user_id) ->
    @perform 'start_hand', {room_id: room_id, user_id: user_id}

  tern_action: (room_id, hand_id, user_id, action_kbn, chip) ->
    @perform 'tern_action', {room_id: room_id, hand_id: hand_id, user_id: user_id, action_kbn: action_kbn, chip: chip}


$(document).on 'click', '#start_hand_button', (event) ->
  App.poker.start_hand $('#room_id').val(), $('#user_id').val()
  event.preventDefault()

$(document).on 'click', '#fold_button', (event) ->
  App.poker.tern_action $('#room_id').val(), $('#hand_id').val(), $('#user_id').val(), ACT_KBN_FOLD, 0
  event.preventDefault()

$(document).on 'click', '#call_button', (event) ->
  App.poker.tern_action $('#room_id').val(), $('#hand_id').val(), $('#user_id').val(), ACT_KBN_CALL, 100
  event.preventDefault()

$(document).on 'click', '#raise_button', (event) ->
  App.poker.tern_action $('#room_id').val(), $('#hand_id').val(), $('#user_id').val(), ACT_KBN_RAISE, Number($('#raise_amount').val())
  event.preventDefault()

do_on_document_readay = ->
  console.log 'in do_on_document_readay poker_channel'

$ ->
  do_on_document_readay()

