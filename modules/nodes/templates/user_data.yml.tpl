#cloud-config
user: ${ssh_user}
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - htop
  - ncdu
  - bash-completion
ssh_authorized_keys:
  - >-
    ${ssh_keys}
write_files:
  # Better debugging while connected to the nodes
  - path: /root/.bashrc
    content: |
      source <(k3s completion bash)
      source <(kubectl completion bash)
      alias k=kubectl
      complete -o default -F __start_kubectl k
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
  - curl -o /var/lib/rancher/k3s/server/manifests/policy.yaml https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes/files/policy.yaml
  - curl -o /var/lib/rancher/k3s/server/manifests/network.yaml https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes/files/network.yaml
  - curl -o /var/lib/rancher/k3s/server/audit.yaml https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes/files/audit.yaml
  - curl -o /etc/rancher/k3s/config.yaml https://raw.githubusercontent.com/dgiebert/harvester-k3s-terraform/develop/modules/nodes/files/${config_yaml}
  - ${registration_cmd}