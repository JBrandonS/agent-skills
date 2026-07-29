#!/usr/bin/env bash
# validate_placeholders.sh — Scan .tex files for unfilled placeholders.
# Usage: ./scripts/validate_placeholders.sh <directory>
# Exit 0 = all clean, 1 = placeholder(s) found.

set -euo pipefail

TARGET_DIR="${1:?Usage: validate_placeholders.sh <directory>}"

if [[ ! -d "$TARGET_DIR" ]]; then
	echo "ERROR: $TARGET_DIR is not a directory" >&2
	exit 1
fi

FOUND=0

for texfile in "$TARGET_DIR"/*.tex; do
	[[ -f "$texfile" ]] || continue
	filename="$(basename "$texfile")"

	# Check each forbidden placeholder set
	while IFS= read -r ph; do
		if grep -qF "[$ph]" "$texfile"; then
			echo "MISSING: [$ph] in $filename"
			FOUND=$((FOUND + 1))
		fi
	done <<'PLACEHOLDERS'
EMAIL
PHONE
LINKEDIN_URL
LINKEDIN_USERNAME
GITHUB_URL
GITHUB_USERNAME
WEBSITE_URL
WEBSITE_NAME
COMPANY_NAME
LOCATION
Position Title
PLACEHOLDERS

done

if [[ $FOUND -gt 0 ]]; then
	echo "" >&2
	echo "VALIDATION FAILED: $FOUND unfilled placeholder(s) in $TARGET_DIR" >&2
	exit 1
else
	echo "OK: All placeholders filled in $(ls "$TARGET_DIR"/*.tex 2>/dev/null | wc -l) file(s)"
	exit 0
fi
