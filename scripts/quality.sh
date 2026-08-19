#!/bin/sh
# Run recurring repository quality gates without stopping at the first failure.

set -u

timestamp=$(date '+%Y%m%dT%H%M%S')
log_dir=".validation-logs/${timestamp}-quality"
mkdir -p "$log_dir"

checks=0
failed=0
skipped=0
failed_checks=""
skipped_checks=""

run_check() {
  check_name=$1
  tool=$2
  shift 2
  checks=$((checks + 1))
  log_file="$log_dir/${checks}-${check_name}.log"

  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Tool unavailable: %s\n' "$tool" >"$log_file"
    skipped=$((skipped + 1))
    skipped_checks="${skipped_checks}${skipped_checks:+, }${check_name} (${tool})"
    return
  fi

  if ! "$@" >"$log_file" 2>&1; then
    failed=$((failed + 1))
    failed_checks="${failed_checks}${failed_checks:+, }${check_name}"
  fi
}

run_advisory_check() {
  check_name=$1
  tool=$2
  shift 2
  checks=$((checks + 1))
  log_file="$log_dir/${checks}-${check_name}.log"

  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Tool unavailable: %s\n' "$tool" >"$log_file"
    skipped=$((skipped + 1))
    skipped_checks="${skipped_checks}${skipped_checks:+, }${check_name} (${tool})"
    return
  fi

  if ! "$@" >"$log_file" 2>&1; then
    skipped=$((skipped + 1))
    skipped_checks="${skipped_checks}${skipped_checks:+, }${check_name} (advisory failure)"
  fi
}

# Autofix recurring formatters first; later checks verify their result.
run_check prettier-fix prettier prettier --write --ignore-unknown README.md AGENTS.md .github docs callback_plugins playbooks roles Dockerfile
run_check ruff-fix ruff ruff check --fix callback_plugins
run_check black-fix black black callback_plugins

# Add only recurring quality gates here; Jinja templates are checked by Ansible.
run_check ansible-lint ansible-lint ansible-lint roles playbooks
run_check yaml-lint yamllint yamllint roles playbooks collections/requirements.yml .github
for playbook in playbooks/*.yml; do
  run_check "syntax-$(basename "$playbook" .yml)" ansible-playbook \
    ansible-playbook --syntax-check "$playbook"
done
run_check prettier-check prettier prettier --check --ignore-unknown README.md AGENTS.md .github docs callback_plugins playbooks roles Dockerfile
run_check ruff-check ruff ruff check callback_plugins
run_check black-check black black --check callback_plugins
run_check python-lint pylint pylint callback_plugins
run_check python-types pyright pyright callback_plugins
run_advisory_check markdown-lint markdownlint markdownlint README.md AGENTS.md docs
run_check dockerfile-lint hadolint hadolint Dockerfile
run_check shell-lint shellcheck shellcheck scripts/quality.sh

if [ "$failed" -eq 0 ]; then
  printf 'RESULT: quality PASS (%s checks, %s skipped); logs: %s\n' "$checks" "$skipped" "$log_dir"
else
  printf 'RESULT: quality FAIL (%s/%s checks, %s skipped); logs: %s\n' "$failed" "$checks" "$skipped" "$log_dir"
  printf 'Failed checks: %s\n' "$failed_checks"
fi

if [ "$skipped" -gt 0 ]; then
  printf 'Warnings: %s\n' "$skipped_checks"
fi

[ "$failed" -eq 0 ]
