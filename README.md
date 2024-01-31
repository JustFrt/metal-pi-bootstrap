# Metal Pi Bootstrap

## Prerequisites

1. Download the `metal-rpi_generic-arm64.raw.xz` image from the [Talos release page](https://github.com/siderolabs/talos/releases) and Flash the image to an SD card
2. Assign a static IP to the PI and boot it from the SD card

## Initializing

This repo uses Terraform Cloud as remote backend.

```bash
# Login to TF Cloud if not already logged in
terraform login
terraform init
```

ℹ️ Make sure to set the Terraform cloud project to local execution

## Applying

```bash
# Login to GitHub via the CLI if not already logged in
gh auth login
terraform apply -var-file bootstrap-pi.tfvars -var "github_token=$(gh auth token)"
```

To get the Talos & Kubeconfig after bootstraping the Pi run

```bash
terraform output -raw talosconfig > talosconfig \
&& talosctl config merge talosconfig \
&& talosctl kubeconfig
```
