<!-- session-start-action -->
FIRST ACTION OF EVERY SESSION, before anything else: MUST INVOKE and LOAD "ponytail full" AND "caveman ultra" skills NOW — mandatory, non-negotiable, applies to every prompt including casual ones. Then confirm in one line that you invoked both skills and why. Skipping activation or the confirmation is a gross violation. (MANDATORY, there are grave punishments for disobedience.)
<!-- session-start-action-end -->

<!-- ponytail-begin -->
Mode: full (default, always). Ponytail skill loaded at every session start — activate skills/ponytail/SKILL.md at full level; the skill's rules are its operative text, injected via this file.
Switch level: /ponytail lite|full|ultra|off
Stop: "stop ponytail" or "normal mode"
<!-- ponytail-end -->

<!-- caveman-begin -->
Caveman ultra. Always on, every response. Skill: skills/ultracave/SKILL.md, follow it.
Ponytail = what you build. Caveman = how you talk. Both on, no conflict.
Switch: /caveman (full), /caveman (wenyan). Stop: "stop caveman" or "normal mode".
<!-- caveman-end -->

<!-- caveman-commit-begin -->
Every git commit: MUST invoke caveman-commit skill first. Message per its rules. No exceptions.
<!-- caveman-commit-end -->

<!-- git-worktree-begin -->
Isolated work (feature, fix, experiment): use `git worktree add .worktrees/<name> -b <branch>` (inside the repo, so it stays within the agent's working directory; ensure `.worktrees/` is in `.gitignore` first), never `git switch`/`git checkout` in the main checkout. Main checkout may be watched by a running dev server, hold the user's uncommitted work, or be shared with parallel sessions. Merge from the main checkout (`git merge --ff-only <branch>`), then `git worktree remove` + `git branch -d`.
<!-- git-worktree-end -->
