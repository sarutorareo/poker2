@user_names = ['ichirou', 'jirou', 'hanako', 'hiyoten', 'robo_hiyoten']

@user_names.each do |name|
  User.create(
    name: name,
    chip: 150000,
    user_type: name.length >= 5 && name[0,5] == 'robo_' ? 1: 0
  )
end
