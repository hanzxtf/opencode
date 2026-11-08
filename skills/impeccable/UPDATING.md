# Updating the impeccable skill

`npx impeccable update` does not work here: it fails to detect this install
(`~/.claude/skills` is a symlink to `~/.config/opencode/skills`) and exits 1
silently. Update from the GitHub release instead.

```sh
V=4.8.1   # latest: gh release list -R pbakaus/impeccable | grep Skill
D=$(mktemp -d) && cd "$D"
gh release download "skill-v$V" -R pbakaus/impeccable
# sha256 must match the "sha256" field in the sig file
sha256sum universal.zip; grep sha256 universal.zip.sig.json
unzip -q universal.zip -d u
rsync -a --delete --exclude UPDATING.md \
  u/.opencode/skills/impeccable/ ~/.config/opencode/skills/impeccable/
```

Then check that it works from any project dir:

```sh
~/.config/opencode/skills/impeccable/scripts/impeccable context
```

Notes:
- Use the `.opencode` build. Its SKILL.md uses `.opencode/skills/impeccable/...` paths.
- The `--exclude UPDATING.md` keeps this file. Without it, `--delete` removes it.
- Since 4.x the `scripts/impeccable` launcher downloads its engine binary
  into `~/.impeccable/bin/` on first run. The download is verified against
  `scripts/engine-checksums.txt`, and nothing is written to this repo.
- Review `git diff --stat skills/impeccable` before committing.
