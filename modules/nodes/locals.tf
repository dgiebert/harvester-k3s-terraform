locals {
  harvester_image = coalescelist(harvester_image.opensuse-leap-15_4, data.harvester_image.opensuse-leap-15_4)[0]
}