#!/usr/bin/env bash
set -euo pipefail

API_BASE="${ZOHO_API_BASE:-https://desk.zoho.eu/api/v1}"
ORG_ID="${ZOHO_ORG_ID:?Missing ZOHO_ORG_ID}"
TOKEN="${ZOHO_ACCESS_TOKEN:?Missing ZOHO_ACCESS_TOKEN}"
ARTICLES_DIR="${ARTICLES_DIR:-articles}"

header_auth=("Authorization: Zoho-oauthtoken ${TOKEN}")
header_org=("orgId: ${ORG_ID}")
header_accept=("Accept: application/json")

request_json() {
  local method="$1"
  local url="$2"
  local data="${3:-}"
  local response
  local body
  local status

  if [ -n "$data" ]; then
    response=$(curl -sS -X "$method" "$url" \
      -H "${header_auth[@]}" -H "${header_org[@]}" -H "${header_accept[@]}" \
      -H "Content-Type: application/json" \
      -d "$data" \
      -w "HTTPSTATUS:%{http_code}")
  else
    response=$(curl -sS -X "$method" "$url" \
      -H "${header_auth[@]}" -H "${header_org[@]}" -H "${header_accept[@]}" \
      -w "HTTPSTATUS:%{http_code}")
  fi

  body="${response%HTTPSTATUS:*}"
  status="${response##*HTTPSTATUS:}"

  if [ "$status" -lt 200 ] || [ "$status" -ge 300 ]; then
    echo "Zoho API error ($method $url): HTTP $status" >&2
    echo "$body" >&2
    exit 1
  fi

  if ! echo "$body" | jq -e '.' >/dev/null 2>&1; then
    echo "Zoho API returned non-JSON response ($method $url):" >&2
    echo "$body" >&2
    exit 1
  fi

  echo "$body"
}

get_frontmatter() {
  awk 'NR==1{if($0!="---"){exit 1}} NR>1{if($0=="---"){exit} print}' "$1"
}

get_content() {
  awk 'BEGIN{c=0} $0=="---"{c++;next} c>=2{print}' "$1"
}

get_value() {
  local key="$1"
  local fm="$2"
  printf '%s\n' "$fm" | sed -n "s/^${key}:[[:space:]]*//p" | head -n 1 | sed 's/^"//;s/"$//'
}

if [ ! -d "$ARTICLES_DIR" ]; then
  echo "Missing articles directory: $ARTICLES_DIR" >&2
  exit 1
fi

for file in "$ARTICLES_DIR"/*; do
  [ -f "$file" ] || continue

  fm=$(get_frontmatter "$file" || true)
  if [ -z "$fm" ]; then
    echo "Skipping $file (missing frontmatter)" >&2
    continue
  fi

  title=$(get_value "title" "$fm")
  status=$(get_value "status" "$fm")
  department_id=$(get_value "department_id" "$fm")
  category_id=$(get_value "category_id" "$fm")
  section_id=$(get_value "section_id" "$fm")
  language=$(get_value "language" "$fm")
  content_type=$(get_value "content_type" "$fm")
  article_id=$(get_value "id" "$fm")

  if [ -z "$title" ] || [ -z "$status" ] || [ -z "$department_id" ] || [ -z "$category_id" ] || [ -z "$section_id" ] || [ -z "$language" ]; then
    echo "Missing required frontmatter in $file" >&2
    exit 1
  fi

  if [ -z "$content_type" ]; then
    content_type="html"
  fi

  content=$(get_content "$file")

  payload=$(jq -n \
    --arg title "$title" \
    --arg status "$status" \
    --arg dept "$department_id" \
    --arg category "$category_id" \
    --arg section "$section_id" \
    --arg language "$language" \
    --arg content "$content" \
    --arg content_type "$content_type" \
    '{title: $title, status: $status, departmentId: $dept, categoryId: $category, sectionId: $section, language: $language, content: $content, contentType: $content_type}'
  )

  if [ -n "$article_id" ]; then
    echo "Updating article $article_id ($title)"
    request_json "PUT" "${API_BASE}/articles/${article_id}" "$payload" > /dev/null
    continue
  fi

  search=$(request_json "GET" "${API_BASE}/articles/search?searchStr=$(printf '%s' "$title" | jq -sRr @uri)&departmentId=${department_id}")
  existing_id=$(echo "$search" | jq -r '.data[0].id // empty')

  if [ -n "$existing_id" ]; then
    echo "Updating article $existing_id ($title)"
    request_json "PUT" "${API_BASE}/articles/${existing_id}" "$payload" > /dev/null
  else
    echo "Creating article ($title)"
    request_json "POST" "${API_BASE}/articles" "$payload" > /dev/null
  fi
 done
