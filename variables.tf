variable "cluster_name" {
  type = string
}

variable "nodes" {
  type = list(string)
}

variable "machine_type" {
  type    = string
  default = "controlplane"
}

variable "talos_config_patches" {
  type = string
}

variable "github_token" {
  sensitive = true
  type      = string
}

variable "github_org" {
  type    = string
  default = "justfrt"
}

variable "github_repository" {
  type    = string
  default = "flux-metal-pi-bts"
}
