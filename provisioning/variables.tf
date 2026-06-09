# ── Secrets ────────────────────────────────────────────────────────────────
# NEVER put these in a committed file. OpenTofu automatically reads any env var
# named TF_VAR_<name>, so export them at apply time and they stay off disk:
#
#   export TF_VAR_hcloud_token="$(op read 'op://Private/Hetzner/api-token')"
#   export TF_VAR_op_service_account_token="$(op read 'op://Private/op-sa/token')"

variable "hcloud_token" {
  description = "Hetzner Cloud API token (Read & Write). Set via TF_VAR_hcloud_token."
  type        = string
  sensitive   = true
}

variable "op_service_account_token" {
  description = <<-EOT
    1Password service-account token. cloud-init writes it to ~/.op-token so
    chezmoi's onepasswordRead works on first boot, then shreds it.

    HEADS UP: this value is baked into the server's user_data, which means it
    lands in your LOCAL tofu state file. That's why state is gitignored and
    must stay on your laptop only. Set via TF_VAR_op_service_account_token.
  EOT
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
  description = "OS image. Keep in sync with the server-support branch (Ubuntu 24.04)."
  type        = string
  default     = "ubuntu-24.04"
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
