# Unlock the Bitwarden CLI with the master password from GNOME Keyring.
bwu() {
  local session
  session=$(BW_PASSWORD=$(secret-tool lookup service bitwarden) bw unlock --passwordenv BW_PASSWORD --raw) || return
  export BW_SESSION=$session
}
