#!/bin/bash
set -e
echo "Downloading Linkerd..."
curl -sL https://run.linkerd.io/install -o install-linkerd.sh
chmod +x install-linkerd.sh
./install-linkerd.sh
export PATH=$PATH:/home/daya/.linkerd2/bin
echo "Linkerd installed."
linkerd version
