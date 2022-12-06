#  kubectl create sa "${SERVICE_ACCOUNT_NAME}" --namespace "${NAMESPACE}"
resource "kubernetes_service_account" "harvester-cloud-provider" {
  metadata {
    name      = "harvester-cloud-provider"
    namespace = var.namespace
  }
}

# kubectl create rolebinding ${ROLE_BINDING_NAME} --serviceaccount=${NAMESPACE}:${SERVICE_ACCOUNT_NAME} --clusterrole=${CLUSTER_ROLE_NAME}
resource "kubernetes_role_binding" "harvester-cloud-provider" {
  metadata {
    name      = kubernetes_service_account.harvester-cloud-provider.metadata[0].name
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "harvesterhci.io:cloudprovider"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.harvester-cloud-provider.metadata[0].name
    namespace = kubernetes_service_account.harvester-cloud-provider.metadata[0].namespace
  }
}

# kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o jsonpath="{.data.token}"
resource "kubernetes_secret_v1" "harvester-cloud-provider" {
  metadata {
    name      = kubernetes_service_account.harvester-cloud-provider.metadata[0].name
    namespace = kubernetes_service_account.harvester-cloud-provider.metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.harvester-cloud-provider.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}

locals {
  additional_manifest = <<-EOF
      apiVersion: v1
      kind: Secret
      metadata:
        name: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].name}
        namespace: kube-system
      type: Opaque
      stringData:
        cloud-provider-config: |
          kind: Config
          apiVersion: v1
          clusters:
          - cluster:
              certificate-authority-data: ${base64encode(kubernetes_secret_v1.harvester-cloud-provider.data["ca.crt"])}
              server: https://192.168.0.37:6443
            name: local
          contexts:
          - context:
              cluster: local
              namespace: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].namespace}
              user: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].name}
            name: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].name}
          current-context: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].name}
          users:
          - name: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].name}
            user:
              token: ${kubernetes_secret_v1.harvester-cloud-provider.data["token"]}
      ---
      apiVersion: helm.cattle.io/v1
      kind: HelmChart
      metadata:
        name: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].name}
        namespace: kube-system
      spec:
        targetNamespace: kube-system
        bootstrap: true
        repo: https://charts.harvesterhci.io/
        chart: harvester-csi-driver
        version: 0.1.14
        helmVersion: v3
        set:
          cloudConfig.secretName: ${kubernetes_service_account.harvester-cloud-provider.metadata[0].name}
    EOF
}

