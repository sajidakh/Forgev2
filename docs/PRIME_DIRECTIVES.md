# PRIME DIRECTIVES

## 0) Philosophy
- Green or **no commit**. Build → Test → **Green** → Commit. Red = fix first.
- Determinism before cleverness. Reproducible builds, no flake.

## 1) Commit Discipline (Scaffolding phase)
- Target branch: **main** only.
- Flow: Build → Test → Green → Commit to `main`.
- Tag meaningful milestones after green (e.g., `v0.1.0-step1`).

## 2) Branch Model (Business Logic phase)
- Create **dev** from `main` when we start feature work:
  - `git checkout -b dev && git push -u origin dev`
- Day-to-day commits: **dev** (Green required).
- Feature complete → merge **dev → main** (squash or conventional merge).
- Post-merge sanity on `main` (smoke). Tag release if green.

## 3) Local Enforcement
- Pre-commit hook runs `.\scripts\run-tests.ps1`.
- If tests fail, commit is **aborted**.
- Manual run anytime: `.\scripts\run-tests.ps1`.

## 4) CI (coming in Step 1a)
- GitHub Actions: run the same tests on push to `main` and `dev`.
- Fail fast, artifact logs, SBOM & safety checks.

## 5) Commit Messages
- Conventional style preferred (e.g., `feat(ui): ...`, `fix(api): ...`, `chore(scripts): ...`, `docs: ...`).

## 6) What “Tests” mean *right now*
- UI compiles (`npm run build`).
- API health returns `ok` via ephemeral boot.
- (We will add unit/integration, lint, type checks, visual/no-flake later.)
