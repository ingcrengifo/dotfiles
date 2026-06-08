#!/bin/sh

set -e

EMAIL="$1"

if [ -z "$EMAIL" ]; then
  echo "Usage: ./ssh.sh <your-email-address>"
  exit 1
fi

echo "Generating a new SSH key for GitHub..."

mkdir -p "$HOME/.ssh"

ssh-keygen -t ed25519 -C "$EMAIL" -f "$HOME/.ssh/github"

touch "$HOME/.ssh/config"

cat > "$HOME/.ssh/config" <<EOF
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github
  IdentitiesOnly yes
EOF

chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/github"
chmod 644 "$HOME/.ssh/github.pub"
chmod 600 "$HOME/.ssh/config"

echo ""
echo "SSH key generated."
echo "Run:"
echo "pbcopy < ~/.ssh/github.pub"
echo ""
echo "Then paste it into:"
echo "GitHub > Settings > SSH and GPG keys > New SSH key"
