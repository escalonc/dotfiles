# Registers your laptop public key with Hetzner. Hetzner injects it into root's
# authorized_keys at create time — a fallback login path. Day to day you log in
# as the `chris` user, whose key is set by cloud-init (see locals below).
resource "hcloud_ssh_key" "laptop" {
  name       = "${var.server_name}-laptop"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# Firewall: permit inbound SSH only from ssh_allowed_ips. Anything not explicitly
# allowed inbound is denied; outbound is unrestricted. Attached to the server below.
resource "hcloud_firewall" "devbox" {
  name = "${var.server_name}-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ssh_allowed_ips
  }
}

# Render cloud-init.yaml, filling its two ${...} placeholders. templatefile only
# substitutes ${...} and %{...}; the shell $(...) inside runcmd is passed through
# untouched. trimspace drops the trailing newline on the pubkey so the YAML stays valid.
locals {
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    laptop_pubkey   = trimspace(file(pathexpand(var.ssh_public_key_path)))
    dotfiles_branch = var.dotfiles_branch
  })
}

# The box itself. Note: cloud-init only runs on FIRST boot, so changing user_data
# (i.e. editing cloud-init.yaml) forces OpenTofu to destroy and recreate the
# server on the next apply — that's how you get a clean re-provision.
resource "hcloud_server" "devbox" {
  name         = var.server_name
  server_type  = var.server_type
  image        = var.image
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.laptop.id]
  firewall_ids = [hcloud_firewall.devbox.id]
  user_data    = local.user_data
}
