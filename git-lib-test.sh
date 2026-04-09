#!/bin/bash
# git-lib-test.sh

source git-lib.sh

load_config

ask_required REPO   "Repositório" "$REPO"
ask_required BRANCH "Branch"      "$BRANCH"

echo "→ $REPO @ $BRANCH"
