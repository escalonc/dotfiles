# Printed after `tofu apply` (and via `tofu output`).
output "ipv4" {
  description = "Public IPv4 address of the devbox."
  value       = hcloud_server.devbox.ipv4_address
}

output "ssh" {
  description = "Ready-to-paste SSH command (log in as the chris user)."
  value       = "ssh chris@${hcloud_server.devbox.ipv4_address}"
}
