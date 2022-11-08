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
data "harvester_clusternetwork" "mgmt" {
  name = "mgmt"
}

resource "harvester_network" "vlan" {
  name        = var.vlan_name
  namespace   = var.namespace
  description = "VLAN used for the cluster ${var.cluster_name} with ID ${var.vlan_id}"

  vlan_id              = var.vlan_id
  route_mode           = "auto"
  cluster_network_name = data.harvester_clusternetwork.mgmt.name

  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}

# Harvester VMs created to serve as server nodes (configured via var.server_vms)
resource "harvester_virtualmachine" "servers" {
  count       = var.server_vms.number
  name        = "server-${count.index}.${var.cluster_name}.${var.domain}"
  description = "This server node belongs to the cluster ${var.cluster_name} running ${harvester_image.opensuse-leap-15_4.display_name}"
  namespace   = var.namespace
  cpu         = var.server_vms.cpu
  memory      = var.server_vms.memory
  efi         = var.efi

  tags = {
    cluster = var.cluster_name
    image   = harvester_image.opensuse-leap-15_4.name
    role    = "server"
  }

  network_interface {
    name         = "nic-1"
    network_name = harvester_network.vlan.id
  }

  disk {
    name        = "root"
    size        = var.server_vms.disk_size
    image       = harvester_image.opensuse-leap-15_4.id
    auto_delete = var.server_vms.auto_delete
  }

  cloudinit {
    user_data = templatefile("${path.module}/templates/user_data.yml.tpl", {
      ssh_keys         = join("\n    ", (values(var.ssh_keys)))
      ssh_user         = var.ssh_user
      registration_cmd = "${var.registration_url} ${var.server_args}"
      config_yaml      = "config_server.yaml"
      hostname         = "server-${count.index}"
      fqdn             = "server-${count.index}.${var.cluster_name}.${var.domain }"
    })
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
  count       = var.agent_vms.number
  name        = "${var.cluster_name}-agent-${count.index}"
  description = "This server node belongs to the cluster ${var.cluster_name} running ${harvester_image.opensuse-leap-15_4.display_name}"
  namespace   = var.namespace
  cpu         = var.agent_vms.cpu
  memory      = var.agent_vms.memory
  efi         = var.efi

  tags = {
    cluster = var.cluster_name
    image   = harvester_image.opensuse-leap-15_4.name
    role    = "agent"
  }

  network_interface {
    name         = "nic-1"
    network_name = harvester_network.vlan.id
  }

  disk {
    name        = "root"
    size        = var.agent_vms.disk_size
    image       = harvester_image.opensuse-leap-15_4.id
    auto_delete = var.agent_vms.auto_delete
  }

  cloudinit {
    user_data = templatefile("${path.module}/templates/user_data.yml.tpl", {
      ssh_keys         = join("\n    ", (values(var.ssh_keys)))
      ssh_user         = var.ssh_user
      registration_cmd = "${var.registration_url} ${var.agent_args}"
      config_yaml      = "config_agent.yaml"
      hostname         = "server-${count.index}"
      fqdn             = "server-${count.index}.${var.cluster_name}.${var.domain}"
    })
  }

  # Make agents depend on the server to allow for -target to hit both
  depends_on = [
    harvester_virtualmachine.servers
  ]
}
