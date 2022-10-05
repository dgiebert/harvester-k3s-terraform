# For better readability
locals {
  cloud_init = templatefile("${path.module}/templates/user_data.yml.tpl", {
    ssh_keys         = join("\n    ", (values(harvester_ssh_key.keys))[*].public_key)
    ssh_user         = var.ssh_user
    registration_cmd = "${var.registration_url} ${var.agent_args}"
  })
}
