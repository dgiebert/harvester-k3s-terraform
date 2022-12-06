output "registration_url" {
  value = "curl -fL ${var.rancher2.url}/system-agent-install.sh | sudo  sh -s - --server ${var.rancher2.url} --token ${rancher2_cluster_v2.default.cluster_registration_token[0].token}"
}

output "cluster_v1_id" {
  value = rancher2_cluster_v2.default.cluster_v1_id
}