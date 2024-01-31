locals {
  # Hardcode var for single node cluster
  talos_node       = var.nodes[0]
  # Define the single node cluster API endpoint
  cluster_endpoint = "https://${var.nodes[0]}:6443"
}


resource "talos_machine_secrets" "this" {}


data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster_name
  machine_type     = var.machine_type
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets

}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = var.nodes
  endpoints            = var.nodes
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = local.talos_node
  config_patches              = [var.talos_config_patches]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = local.talos_node
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.talos_node
}

resource "null_resource" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOT
      retries=0
      until [ $retries -ge 3 ]; do
        if curl --fail \
                --retry 60 \
                --retry-connrefused \
                --retry-delay 10 \
                --cert <(echo '${data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate}' | base64 --decode) \
                --key <(echo '${data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key}' | base64 --decode) \
                --cacert <(echo '${data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate}' | base64 --decode) \
                ${local.cluster_endpoint}/healthz; then
          exit 0
        else
          retries=$[$retries+1]
          sleep 10
        fi
      done
    EOT
  }
}
