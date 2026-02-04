#!/usr/bin/env bash
set -euo pipefail
cd ~/apps
wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar xf google-cloud-cli-linux-x86_64.tar.gz
symfarm ~/apps/google-cloud-sdk
rm google-cloud-cli-linux-x86_64.tar.gz
