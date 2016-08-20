$ ->
  $('.enter_button').click ->
    console.log 'id =' +  @id
    room_id = @id[5..@id.length-1]
    console.log 'room_' + room_id + ' clicked '
    window.location.href = 'rooms/' + room_id + '?user_id=' + $('#user_select option:selected').val()
    return
  return
