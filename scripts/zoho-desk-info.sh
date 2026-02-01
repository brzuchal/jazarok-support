#!/usr/bin/env bash
set -euo pipefail

API_BASE="${ZOHO_API_BASE:-https://desk.zoho.eu/api/v1}"
ORG_ID="${ZOHO_ORG_ID:?Missing ZOHO_ORG_ID}"
TOKEN="${ZOHO_ACCESS_TOKEN:?Missing ZOHO_ACCESS_TOKEN}"

header_auth=("Authorization: Zoho-oauthtoken ${TOKEN}")
header_org=("orgId: ${ORG_ID}")

curl -sS -X GET "${API_BASE}/departments" -H "${header_auth[@]}" -H "${header_org[@]}" | jq -r '.data[] | "department: \(.name) \(.id)"'

# List categories per department
for dept_id in $(curl -sS -X GET "${API_BASE}/departments" -H "${header_auth[@]}" -H "${header_org[@]}" | jq -r '.data[].id'); do
  curl -sS -X GET "${API_BASE}/categories?departmentId=${dept_id}" -H "${header_auth[@]}" -H "${header_org[@]}" | jq -r --arg dept "$dept_id" '.data[] | "category: \($dept) \(.name) \(.id)"'
  for cat_id in $(curl -sS -X GET "${API_BASE}/categories?departmentId=${dept_id}" -H "${header_auth[@]}" -H "${header_org[@]}" | jq -r '.data[].id'); do
    curl -sS -X GET "${API_BASE}/sections?categoryId=${cat_id}" -H "${header_auth[@]}" -H "${header_org[@]}" | jq -r --arg cat "$cat_id" '.data[] | "section: \($cat) \(.name) \(.id)"'
  done
 done
