#!/bin/bash

# copying local ssh public key to romote hosts
ssh-copy-id -f -i ~/.ssh/id_ed25519.pub moses@10.0.0.5
ssh-copy-id -f -i ~/.ssh/id_ed25520.pub moses@10.0.0.6
ssh-copy-id -f -i ~/.ssh/id_ed25519.pub moses@10.0.0.11
ssh-copy-id -f -i ~/.ssh/id_ed25519.pub moses@10.0.0.12
ssh-copy-id -f -i ~/.ssh/id_ed25519.pub moses@10.0.0.13

# caching ssh private key
eval "$(ssh-agent)"
ssh-add ~/.ssh/id_ed25519
