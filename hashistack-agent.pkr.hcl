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
# HashiAgent - nomad agent reciepe
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
# HashiAgent - nomad agent reciepe - END
# HashiAgent - consul agent reciepe
  provisioner "shell" {
    inline = [
      "curl --silent --remote-name https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip",
      "curl --silent --remote-name https://releases.hashicorp.com/1.8.0/consul_1.8.0_SHA256SUMS",
      "curl --silent --remote-name https://releases.hashicorp.com/1.8.0/consul_1.8.0_SHA256SUMS.sig",
      "unzip consul_1.8.0_linux_amd64.zip",
      "sudo chown root:root consul",
      "sudo mv consul /usr/bin/",
      "consul --version",
      "sudo touch /etc/systemd/system/consul.service",
      "sudo mkdir --parents /opt/consul",
      "sudo mkdir --parents /etc/consul.d",
      "sudo touch /etc/consul.d/consul.hcl",
      "sudo chmod 640 /etc/consul.d/consul.hcl",
      "sudo useradd --system --home /etc/consul.d --shell /bin/false consul",
      "sudo chown --recursive consul:consul /opt/consul",
      "sudo chown --recursive consul:consul /etc/consul.d",
    ]
  }
  provisioner "file" {
    source      = "consul.service"
    destination = "/tmp/"
  }
  provisioner "file" {
    source      = "consul.hcl"
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo chown root:root /etc/systemd/system/consul.service",
      "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
      "sudo chown consul:consul /etc/consul.d/consul.hcl",
      "sudo systemctl enable consul",
      "sudo systemctl start consul",
      "sudo systemctl status consul",
    ]
  }
# HashiAgent - consul agent reciepe - END
# GCP - ops-agent reciepe
  provisioner "shell" {
    inline = [
      "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh",
      "sudo bash add-google-cloud-ops-agent-repo.sh --also-install",
      "touch /etc/google-cloud-ops-agent/config.yaml",
    ]
  }
  provisioner "file" {
    source = "config.yaml"
    destination = "/etc/google-cloud-ops-agent/"
  }
# GCP - ops-agent reciepe - END
}