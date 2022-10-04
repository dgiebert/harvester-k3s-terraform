# Operating System Image (OpenSuse Leap)
resource "harvester_image" "opensuse-leap-15_4" {
  name         = "opensuse-leap-15.4"
  namespace    = var.namespace
  description  = "openSUSE Leap 15.4 NoCloud x86_64"
  display_name = "openSUSE Leap 15.4"
  source_type  = "download"
  url          = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/openSUSE-Leap-15.4.x86_64-NoCloud.qcow2"
}

# VLAN Network
resource "harvester_network" "vlan" {
  name        = "vlan-${local.cluster.name}-${var.vlan_id}"
  namespace   = var.namespace
  description = "VLAN used for the cluster ${local.cluster.name} with ID ${var.vlan_id}"

  vlan_id = var.vlan_id

  route_mode = "auto"

  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}

# SSH Keys created using a for loop over the var.ssh_keys map
resource "harvester_ssh_key" "keys" {
  for_each = var.ssh_keys

  name        = each.key
  description = "SSH Key for ${each.key}"
  namespace   = var.namespace
  public_key  = each.value
}

# Harvester VMs created to serve as server nodes (configured via var.server_vms)
resource "harvester_virtualmachine" "servers" {
  count       = local.server_vms.number
  name        = "${local.cluster.name}-server-${count.index}"
  description = "This server node belongs to the cluster ${local.cluster.name} running ${harvester_image.opensuse-leap-15_4.display_name}"
  namespace   = var.namespace
  cpu         = local.server_vms.cpu
  memory      = local.server_vms.memory
  efi         = var.efi

  tags = {
    cluster = local.cluster.name
    image   = harvester_image.opensuse-leap-15_4.name
    role    = "server"
  }

  network_interface {
    name         = "nic-1"
    network_name = harvester_network.vlan.id
  }

  disk {
    name        = "root"
    size        = local.server_vms.disk_size
    image       = harvester_image.opensuse-leap-15_4.id
    auto_delete = local.server_vms.auto_delete
  }

  cloudinit {
    user_data = templatefile("${path.module}/templates/user_data.yml.tpl", {
      ssh_keys         = values(harvester_ssh_key.keys),
      ssh_user         = var.ssh_user
      registration_cmd = "${local.registration_url} ${local.cluster.server_args}"
    })
    network_data = local.cloud_init.network_data
  }
  # This is to ignore volumes added using the CSI Provider
  lifecycle {
    ignore_changes = [
      disk,
    ]
  }
}

# Harvester VMs created to serve as agent nodes (configured via var.agent_vms)
resource "harvester_virtualmachine" "agents" {
  count       = local.agent_vms.number
  name        = "${local.cluster.name}-agent-${count.index}"
  description = "This server node belongs to the cluster ${local.cluster.name} running ${harvester_image.opensuse-leap-15_4.display_name}"
  namespace   = var.namespace
  cpu         = local.agent_vms.cpu
  memory      = local.agent_vms.memory
  efi         = var.efi

  tags = {
    cluster = local.cluster.name
    image   = harvester_image.opensuse-leap-15_4.name
    role    = "agent"
  }

  network_interface {
    name         = "nic-1"
    network_name = harvester_network.vlan.id
  }

  disk {
    name        = "root"
    size        = local.agent_vms.disk_size
    image       = harvester_image.opensuse-leap-15_4.id
    auto_delete = local.agent_vms.auto_delete
  }

  cloudinit {
    user_data = templatefile("${path.module}/templates/user_data.yml.tpl", {
      ssh_keys         = values(harvester_ssh_key.keys),
      ssh_user         = var.ssh_user
      registration_cmd = "${local.registration_url} ${local.cluster.agent_args}"
    })
    network_data = local.cloud_init.network_data
  }

  # Make agents depend on the server to allow for -target to hit both
  depends_on = [
    harvester_virtualmachine.servers
  ]
}