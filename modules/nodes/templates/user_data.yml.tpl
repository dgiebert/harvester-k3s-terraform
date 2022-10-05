{assign url="https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes"}
#cloud-config
user: ${ssh_user}
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - htop
  - ncdu
ssh_authorized_keys:
  - >-
    ${ssh_keys}
write_files:
  - path: /etc/sysctl.d/90-kubelet.conf
    content: |
      vm.panic_on_oom=0
      vm.overcommit_memory=1
      kernel.panic=10
      kernel.panic_on_oops=1
      kernel.keys.root_maxbytes=25000000
  - path: /etc/sysctl.d/90-rke2.conf
    content: |
      net.ipv4.conf.all.forwarding=1
      net.ipv6.conf.all.forwarding=1
runcmd:
  - systemctl enable --now qemu-guest-agent
  - sysctl -p /etc/sysctl.d/90-kubelet.conf /etc/sysctl.d/90-rke2.conf
  - mkdir -p -m 700 /var/lib/rancher/k3s/server/logs
  - mkdir -p /var/lib/rancher/k3s/server/manifests/ /etc/rancher/k3s/
  - curl ${url}/files/policy.yaml -o /var/lib/rancher/k3s/server/manifests/policy.yaml
  - curl ${url}/files/network.yaml -o /var/lib/rancher/k3s/server/manifests/network.yaml
  - curl ${url}/files/audit.yaml -o /var/lib/rancher/k3s/server/audit.yaml
  - curl ${url}/files/config.yaml -o /etc/rancher/k3s/config.yaml
  - ${registration_cmd}