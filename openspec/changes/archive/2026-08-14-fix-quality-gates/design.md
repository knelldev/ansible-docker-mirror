## Design

Use a POSIX shell script with one repository-wide run. Each check gets its own
log file under ignored `.validation-logs/`; the script does not stop after the
first failure.

### Check order

1. Autofix: Prettier for supported repository text/JSON files, Ruff for Python,
   and Black for Python.
2. Post-fix verification: Prettier check, Ruff check, Black check, ansible-lint,
   yamllint, root playbook syntax checks, Pyright, hadolint, and advisory
   markdownlint and shellcheck.

Jinja is covered through Ansible. Unavailable tools produce warnings and do not
fail the run. Markdownlint and shellcheck are advisory when available.

### Extension rule

The check list remains easy to extend, but additions must be recurring quality
or test gates that reduce repeated work. One-time wrappers are out of scope.
