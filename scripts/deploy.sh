#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
org_alias="${1:-handoff-portfolio}"
command -v sf >/dev/null || { echo 'Install the official Salesforce CLI first.'; exit 1; }
python3 scripts/check-package.py
org_json="$(sf data query --target-org "$org_alias" --query 'SELECT OrganizationType FROM Organization' --json)"
printf '%s' "$org_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); rows=d.get("result",{}).get("records",[]); assert len(rows)==1 and rows[0]["OrganizationType"]=="Developer Edition", "Deploy only to the intended Developer Edition practice org"'
sf project deploy start --target-org "$org_alias" --manifest manifest/core.xml --dry-run --test-level RunSpecifiedTests --tests SH_HandoffTests --wait 10
sf project deploy start --target-org "$org_alias" --manifest manifest/core.xml --test-level RunSpecifiedTests --tests SH_HandoffTests --wait 10
# Reporting must resolve the newly created fields through the deploying user's access.
sf org assign permset --target-org "$org_alias" --name SH_Sales SH_Coordinator
sf project deploy start --target-org "$org_alias" --source-dir force-app/main/default/reports --source-dir force-app/main/default/dashboards --wait 10
echo 'Core/tests and reporting deployed. Follow docs/implementation.md for layout and queue membership; seed once using scripts/seed-demo.apex.'
