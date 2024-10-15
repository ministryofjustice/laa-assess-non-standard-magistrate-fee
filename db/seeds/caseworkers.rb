return unless ENV.fetch('ENV', 'local').in?(%w[development local])

case_worker = User.find_or_initialize_by(email: 'case.worker@test.com')
case_worker.update(
  first_name: 'case',
  last_name: 'worker',
  auth_oid: SecureRandom.uuid,
  auth_subject_id: SecureRandom.uuid,
)
case_worker.roles.create! role_type: 'caseworker'

super_visor = User.find_or_initialize_by(email: 'super.visor@test.com')
super_visor.update(
  first_name: 'super',
  last_name: 'visor',
  auth_oid: SecureRandom.uuid,
  auth_subject_id: SecureRandom.uuid,
)
super_visor.roles.create! role_type: 'supervisor'

viewer = User.find_or_initialize_by(email: 'viewer@test.com')
viewer.update(
  first_name: 'Reid',
  last_name: "O'Nly",
  auth_subject_id: SecureRandom.uuid,
)
viewer.roles.create! role_type: 'viewer'
