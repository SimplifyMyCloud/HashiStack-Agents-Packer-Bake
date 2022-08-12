datacenter = "dc1"
data_dir = "/opt/consul"
encrypt = "needsValue"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true

ca_file = "/opt/consul/certs/consul-agent-ca.pem"

auto_encrypt {
  tls = true
}
