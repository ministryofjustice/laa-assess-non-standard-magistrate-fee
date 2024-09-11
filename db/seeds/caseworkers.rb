return unless ENV.fetch('ENV', 'local').in?(%w[development local])

case_worker = User.find_or_initialize_by(email: 'case.worker@test.com')
case_worker.update(
  first_name: 'case',
  last_name: 'worker',
  role: 'caseworker',
  auth_oid: SecureRandom.uuid,
  auth_subject_id: SecureRandom.uuid,
)

case_worker = User.find_or_initialize_by(email: 'super.visor@test.com')
case_worker.update(
  first_name: 'super',
  last_name: 'visor',
  role: 'supervisor',
  auth_oid: SecureRandom.uuid,
  auth_subject_id: SecureRandom.uuid,
)

viewer = User.find_or_initialize_by(email: 'viewer@test.com')
viewer.update(
  first_name: 'Reid',
  last_name: "O'Nly",
  role: 'viewer',
  auth_subject_id: SecureRandom.uuid,
)
