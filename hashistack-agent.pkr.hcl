# bakery reciepe to ensure a fully deployable HashiStack Agent
# server that relies on GCP Service Accounts for all functions
# like auto-scaling & auto-healing.
source "googlecompute" "hashistack-agent" {
  project_id              = "simplifymycloud-dev"
  source_image            = "debian-base"
  source_image_project_id = ["simplifymycloud-dev"]
  ssh_username            = "packer"
  use_os_login            = true
  zone                    = "us-west1-c"
  subnetwork              = "smc-dev-subnet-01"
  image_name              = "hashistack-agent"
  image_description       = "HashiStack Agent, Nomad + Consul"
  image_storage_locations = ["us-west1"]
}

build {
  sources = ["sources.googlecompute.hashistack-agent"]
  provisioner "shell" {
    inline = [
      "curl --silent --remote-name https://releases.hashicorp.com/nomad/1.1.0/nomad_1.1.0_linux_amd64.zip",
      "unzip nomad_1.1.0_linux_amd64.zip",
      "sudo chown root:root nomad",
      "sudo mv nomad /usr/local/bin/",
      "nomad version",
      "sudo touch /etc/systemd/system/nomad.service",
      "sudo mkdir --parents /opt/nomad",
      "sudo mkdir --parents /etc/nomad.d",
      "sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad",
      "sudo chmod 700 /etc/nomad.d",
      "sudo touch /etc/nomad.d/nomad.hcl",
      "sudo touch /etc/nomad.d/client.hcl",
    ]
  }
  provisioner "file" {
    source      = "nomad.service"
    destination = "/tmp/"
  }
  provisioner "file" {
    source      = "nomad.hcl"
    destination = "/tmp/"
  }
  provisioner "file" {
    source      = "client.hcl"
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service",
      "sudo chown root:root /etc/systemd/system/nomad.service",
      "sudo mv /tmp/nomad.hcl /etc/nomad.d/nomad.hcl",
      "sudo chown nomad:nomad /etc/nomad.d/nomad.hcl",
      "sudo mv /tmp/client.hcl /etc/nomad.d/client.hcl",
      "sudo chown nomad:nomad /etc/nomad.d/client.hcl",
    ]
  }
}