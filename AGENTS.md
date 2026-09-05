# Agent Instructions

## Git workflow

- Commit straight to `main`. This is a personal dotfiles/Ansible config repo,
  not a shared project with PR review — don't create a topic branch per
  change by default.
- Only branch when asked to, or when a change is large/risky/experimental
  enough that you'd want to abandon it easily.
- Still only commit (or push) when the user asks for it.

## Commit messages

- Conventional Commits style: `type(scope): description`
  (e.g. `feat(nvim): ...`, `fix(hammerspoon): ...`, `chore(shells): ...`).
- Scope is usually the affected role/directory under `roles/`.
- Imperative, concise summary line; add a body only when the change needs
  explaining beyond the diff.
