0.upto(9) do |idx|
  Room.create(
    name: "Room#{format("%03d", idx+1)}",
    # max_user: default,
    # pass: default
  )
end
