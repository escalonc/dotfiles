# ── Secret ───────────────────────────────────────────────────────────────--
# NEVER put this in a committed file. OpenTofu automatically reads any env var
# named TF_VAR_<name>, so export it at apply time and it stays off disk:
#
#   export TF_VAR_hcloud_token="$(op read 'op://Private/Hetzner/api-token')"

variable "hcloud_token" {
  description = "Hetzner Cloud API token (Read & Write). Set via TF_VAR_hcloud_token."
  type        = string
  sensitive   = true
}

# ── Machine shape (safe to commit; tweak freely) ─────────────────────────────

variable "server_name" {
  description = "Name shown in the Hetzner console; also used to name the key/firewall."
  type        = string
  default     = "devbox"
}

variable "server_type" {
  description = "Hetzner server type. cpx41 = 8 vCPU / 16 GB RAM (AMD, x86_64)."
  type        = string
  default     = "cpx41"
}

variable "location" {
  description = "Hetzner location: fsn1/nbg1 (Germany), hel1 (Finland), ash/hil (US)."
  type        = string
  default     = "fsn1"
}

variable "image" {
  description = <<-EOT
    Hetzner OS image. The server-support branch targets Fedora. Hetzner only
    keeps the latest Fedora releases, so this pin goes stale — CONFIRM the exact
    name before first apply: `hcloud image list --type system | grep -i fedora`
    (or check the Hetzner console), then bump if needed.
  EOT
  type        = string
  default     = "fedora-42"
}

variable "ssh_public_key_path" {
  description = "Path to YOUR laptop's public key; added to root and the chris user."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_allowed_ips" {
  description = <<-EOT
    CIDRs allowed to reach SSH (port 22). Default is open to the world, which is
    OK with key-only auth — but tighter is better. Lock it to your home IP in
    terraform.tfvars: ssh_allowed_ips = ["1.2.3.4/32"]  (find it: curl -s ifconfig.me)
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}
