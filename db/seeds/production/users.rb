@user_names = ['robo_hiyoten', 'ichirou', 'jirou', 'hanako', 'hiyoten']

@user_names.each do |name|
  if name == 'robo_hiyoten'
    User.create(
      id: 0,
      name: name,
      chip: 150000,
      user_type: name.length >= 5 && name[0,5] == 'robo_' ? 1: 0
    )
  else
    User.create(
      name: name,
      chip: 150000,
      user_type: name.length >= 5 && name[0,5] == 'robo_' ? 1: 0
    )
  end
end
