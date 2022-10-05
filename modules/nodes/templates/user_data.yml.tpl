#cloud-config
user: ${ssh_user}
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
ssh_authorized_keys:
  - >-
    ${ssh_keys}
write_files:
  - path: /etc/rancher/rke2/config.yaml
    content: |
      secrets-encryption: "true"
      protect-kernel-defaults: "true"
      kube-apiserver-arg:
      - "enable-admission-plugins=NodeRestriction,PodSecurityPolicy,ServiceAccount"
      - 'audit-log-path=/var/lib/rancher/k3s/server/logs/audit.log'
      - 'audit-policy-file=/var/lib/rancher/k3s/server/audit.yaml'
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
  - sudo systemctl enable --now qemu-guest-agent
  - sudo sysctl -p /etc/sysctl.d/90-kubelet.conf
  - sudo sysctl -p /etc/sysctl.d/90-rke2.conf
  - sudo mkdir -p -m 700 /var/lib/rancher/k3s/server/logs
  - sudo mkdir -p /var/lib/rancher/k3s/server/manifests/
  - sudo curl -o /var/lib/rancher/k3s/server/manifests/policy.yaml https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes/files/policy.yaml
  - sudo curl -o /var/lib/rancher/k3s/server/manifests/network.yaml https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes/files/network.yaml
  - sudo curl -o /var/lib/rancher/k3s/server/audit.yaml https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes/files/audit.yaml
  - ${registration_cmd}