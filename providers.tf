terraform {
  required_version = ">=1.1.5"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0-alpha.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.1.2"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}

provider "flux" {
  kubernetes = {
    host                   = "https://${var.nodes[0]}:6443"
    cluster_ca_certificate = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}
