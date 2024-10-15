namespace :user do
  desc 'add user to database'

  task :add, [:email, :first_name, :last_name, :role] => [:environment] do |t, args|
    user = User.find_or_initialize_by(email: args[:email])
    user.update!(
      first_name: args[:first_name],
      last_name: args[:last_name],
      auth_oid: SecureRandom.uuid
    )
    user.roles.create! role_type: args[:role]
  end
end
