## Tasks

- [ ] Replace `ansible.cfg` with the approved concise configuration, preserving existing colors and commented color options.
- [ ] Remove explicit global `gather_subset = all` and remove redundant cowsay settings.
- [ ] Add `--no-cache` to Ruff autofix and check commands in `scripts/quality.sh`.
- [ ] Delete obsolete `ansible.cfg.new`.
- [ ] Run `ansible-config dump --only-changed` and verify paths, callbacks, collection discovery, interpreter, inventory, and SSH settings.
- [ ] Run `git diff --check` and the relevant repository quality checks.
- [ ] Record verification evidence and mark completed tasks.
