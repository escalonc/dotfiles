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

variable "dotfiles_branch" {
  description = <<-EOT
    Branch of the dotfiles repo that cloud-init clones on first boot. Defaults to
    main; override (e.g. "server-support") only while testing a branch before merge.
  EOT
  type        = string
  default     = "main"
}

variable "ssh_public_key_path" {
  description = "Path to YOUR laptop's public key; added to root and the chris user."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_allowed_ips" {
  description = <<-EOT
    CIDRs allowed to reach SSH (port 22). REQUIRED — no default, so you can't
    accidentally open SSH to the world. Lock it to your home IP in
    terraform.tfvars: ssh_allowed_ips = ["1.2.3.4/32"]  (find it: curl -s ifconfig.me)
    To intentionally open it up, set ["0.0.0.0/0", "::/0"] explicitly.
  EOT
  type        = list(string)

  validation {
    condition     = length(var.ssh_allowed_ips) > 0
    error_message = "Set ssh_allowed_ips (e.g. [\"<your-ip>/32\"]); leaving it empty would block all SSH."
  }
}
