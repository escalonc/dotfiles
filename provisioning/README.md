# provisioning/ — the remote devbox as code

OpenTofu config that creates the Hetzner dev box. It manages the **machine**
(server, SSH key, firewall); `cloud-init.yaml` + chezmoi own the **software**
inside it. One `tofu apply` replaces the old "click create, paste cloud-init" dance.

## Files

| File | What it's for |
|------|---------------|
| `versions.tf` | Pins OpenTofu + the `hcloud` provider |
| `variables.tf` | Inputs (tokens, server type, location, SSH allow-list) |
| `main.tf` | The SSH key, firewall, and server resources |
| `outputs.tf` | Prints the IP + an `ssh` command after apply |
| `cloud-init.yaml` | First-boot script, rendered by `main.tf` (a template) |
| `terraform.tfvars.example` | Copy to `terraform.tfvars` to override defaults |
| `.gitignore` | Keeps state + real tfvars out of git |

## One-time setup

1. **Install OpenTofu** — `brew install opentofu`
2. **Two secrets, as env vars** (never in a file). Adjust the `op://` paths:
   ```sh
   export TF_VAR_hcloud_token="$(op read 'op://Private/Hetzner/api-token')"
   export TF_VAR_op_service_account_token="$(op read 'op://Private/op-sa/token')"
   ```
   - `hcloud_token`: Hetzner console → project → Security → API Tokens → Read & Write.
   - `op_service_account_token`: the 1Password service account chezmoi reads secrets with.
3. *(Optional but recommended)* `cp terraform.tfvars.example terraform.tfvars` and
   lock SSH to your IP.

## Daily commands

```sh
cd provisioning
tofu init       # first time only: downloads the provider
tofu plan       # preview — shows exactly what will be created/changed
tofu apply      # do it; prints the box's IP and an ssh command
tofu output ssh # reprint the ssh command later
tofu destroy    # tear it all down (stop paying Hetzner)
```

## Gotchas

- **Editing `cloud-init.yaml` rebuilds the box.** cloud-init only runs on first
  boot, so changing it forces a destroy+recreate on the next `apply`. That's the
  intended way to re-provision cleanly — just know `apply` isn't always harmless.
- **The 1Password token ends up in local state.** It's baked into the server's
  `user_data`. That's why `*.tfstate` is gitignored and must stay on your laptop.
- **`tofu` vs `terraform`.** Identical commands; this repo uses OpenTofu. If you
  have `terraform` installed instead, every command above works by swapping the name.
