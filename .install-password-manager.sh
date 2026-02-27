#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type password-manager-binary >/dev/null 2>&1 && exit

# Install proton-pass cli on linux and macos
curl -fsSL https://proton.me/download/pass-cli/install.sh | bash

echo "Proton Pass CLI installed successfully."

pass-cli login --interactive
