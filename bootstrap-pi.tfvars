cluster_name = "metal-pi-bts"
nodes = [
  "192.168.0.11"
]
talos_config_patches = <<EOT
cluster:
  allowSchedulingOnControlPlanes: true
machine:
  install:
    disk: "/dev/mmcblk0"
EOT
