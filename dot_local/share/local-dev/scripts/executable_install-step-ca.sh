#!/bin/bash

# 1. Export the Root CA from the container
echo "Extracting Root CA from step-ca..."
docker exec step-ca step ca root dev-root-ca.crt

# 2. Install into macOS System Keychain (Chrome/Safari/System)
echo "Installing into macOS Keychain..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain dev-root-ca.crt

# 3. Handle Firefox (Fixed Database logic)
if command -v certutil &>/dev/null; then
  echo "Updating Firefox profiles..."
  # Close Firefox to release database locks
  killall firefox 2>/dev/null

  # Locate all cert9.db files
  find ~/Library/Application\ Support/Firefox/Profiles -name "cert9.db" | while read -r certDB; do
    certDir=$(dirname "$certDB")
    echo "Processing profile: $certDir"

    # We delete any existing 'LocalDev' entry first to avoid conflicts
    certutil -D -n "LocalDev CA" -d "sql:$certDir" 2>/dev/null

    # Add the certificate
    certutil -A -n "LocalDev CA" -t "TCu,Cu,Tu" -i dev-root-ca.crt -d "sql:$certDir"

    if [ $? -eq 0 ]; then
      echo "Successfully updated $certDir"
    else
      echo "Failed to update $certDir. Ensure Firefox is closed."
    fi
  done
else
  echo "Error: certutil not found. Run 'brew install nss' first."
fi

