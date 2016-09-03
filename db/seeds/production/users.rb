@user_names = ['ichirou', 'jirou', 'hanako', 'hiyoten']

@user_names.each do |name|
  User.create(
    name: name,
    chip: 150000
  )
end
