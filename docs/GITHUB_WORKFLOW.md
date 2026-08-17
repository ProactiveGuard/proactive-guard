# GitHub Workflow & Traffic Control

## Golden Rule
**Always `git pull` before you commit/push.** No exceptions.

---

## Branch Workflow

### Main Branches
| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Production-ready code | Protected - PR required |
| `develop` | Integration branch | PR required |

### Feature Branches
**Naming convention:** `<member>/<feature-short-description>`

Examples:
- `member1/sos-button-ui`
- `member2/dashboard-map-integration`
- `member3/audio-motion-sensors`
- `member4/backend-incidents-api`
- `member5/ai-risk-engine`
- `member6/integration-docs`

### Branch Lifecycle
```
main ← develop ← feature/member1/sos-button
                    ← feature/member2/dashboard-map
                    ← feature/member4/backend-api
```

---

## Safe Pull/Commit/Push Sequence

### Before Starting Work
```bash
# 1. Switch to develop and pull latest
git checkout develop
git pull origin develop

# 2. Create your feature branch
git checkout -b member1/sos-button-ui

# 3. Work on your feature...
```

### During Development (Frequent Commits)
```bash
# Stage changes
git add .

# Commit with conventional message
git commit -m "feat(member1): add SOS button with confirmation dialog"

# Push to your feature branch (safe - no one else works here)
git push origin member1/sos-button-ui
```

### Before Creating Pull Request
```bash
# 1. Fetch latest develop
git fetch origin

# 2. Rebase your branch onto latest develop
git rebase origin/develop

# 3. Resolve any conflicts (see Conflict Resolution below)

# 4. Push with force-with-lease (safer than --force)
git push origin member1/sos-button-ui --force-with-lease
```

### After PR Approved & Merged
```bash
# 1. Switch back to develop
git checkout develop

# 2. Pull latest (includes your merged PR)
git pull origin develop

# 3. Delete local feature branch
git branch -d member1/sos-button-ui

# 4. Delete remote feature branch (optional)
git push origin --delete member1/sos-button-ui
```

---

## How to Avoid Merge Conflicts

### 1. Pull Frequently
- Pull `develop` at start of each work session
- Pull `develop` before every commit if working long sessions

### 2. Small, Focused Commits
- One logical change per commit
- Easier to review, easier to resolve conflicts

### 3. Communicate Overlapping Work
- If two members touch same file, coordinate in team chat
- Member 6 (Integration Lead) tracks cross-component changes

### 4. File Ownership Guidelines
| Area | Primary Owner | Coordinate Before Editing |
|------|---------------|---------------------------|
| `backend/app/api/routes/` | Member 4 | All |
| `backend/ai-engine/` | Member 5 | Member 4, Member 6 |
| `dashboard/src/components/` | Member 2 | Member 6 |
| `dashboard/src/lib/supabase.ts` | Member 2 | Member 4, Member 6 |
| `mobile/lib/services/api.dart` | Member 1 | Member 4, Member 6 |
| `mobile/lib/utils/constants.dart` | Member 1 | Member 6 |
| `docs/` | Member 6 | All |

---

## What to Do When Merge Conflicts Occur

### During Rebase (Recommended Approach)
```bash
# 1. Git will pause at conflicting commit
# 2. Check conflicted files
git status

# 3. Open each conflicted file, resolve manually
#    Look for <<<<<<< HEAD, =======, >>>>>>> markers

# 4. Stage resolved files
git add <resolved-file>

# 5. Continue rebase
git rebase --continue

# 6. Repeat until rebase complete
```

### During Merge (If PR has conflicts)
```bash
# 1. Checkout develop locally
git checkout develop
git pull origin develop

# 2. Merge your branch (or rebase)
git merge member1/sos-button-ui

# 3. Resolve conflicts in IDE/editor

# 4. Commit resolution
git add .
git commit -m "chore: resolve merge conflicts with develop"

# 5. Push
git push origin develop
```

### Conflict Resolution Tips
- **Never discard someone else's changes without talking to them**
- Use VS Code "Merge Editor" or `git mergetool`
- For `.env` conflicts: **always keep your local `.env`**, never commit it
- For `package.json` / `pubspec.yaml`: merge dependencies carefully
- When in doubt: ask Member 6 (Integration Lead)

---

## Never Commit These Files

### Absolute Forbidden (Gitignored - but double-check)
```
.env
.env.*
*.key
*.secret
*.pem
service-account.json
google-services.json
```

### If Accidentally Committed
```bash
# 1. Remove from git history (if recent)
git rm --cached .env
git commit -m "chore: remove .env from tracking"

# 2. If pushed, rotate ALL secrets immediately!
#    - Supabase keys
#    - Gemini API key
#    - Any other API keys

# 3. Add to .gitignore if missing
echo ".env" >> .gitignore
```

---

## Commit Message Convention

**Format:** `<type>(<scope>): <description>`

### Types
| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code restructure |
| `test` | Adding tests |
| `chore` | Build, deps, config |

### Scopes
`member1`, `member2`, `member3`, `member4`, `member5`, `member6`, `backend`, `dashboard`, `mobile`, `ai`, `docs`

### Examples
```
feat(member4): add POST /incidents/sos endpoint
fix(member2): resolve map marker not updating
docs(member6): add integration test checklist
chore(member5): update Gemini API model version
refactor(backend): extract risk calculation to service
```

---

## PR Checklist (Before Requesting Review)

- [ ] Branch rebased on latest `develop`
- [ ] All tests pass locally
- [ ] No `.env` or secret files in diff
- [ ] Commit messages follow convention
- [ ] PR description explains **what** and **why**
- [ ] Linked to relevant issue/task
- [ ] Self-reviewed diff in GitHub
- [ ] Tag Member 6 for integration review

---

## Release Tagging (Day 5)

```bash
# On develop branch, after all integration tests pass
git checkout develop
git pull origin develop

# Create annotated tag
git tag -a v1.0-submission -m "SIH 2026 Submission - Proactive Guard"

# Push tag
git push origin v1.0-submission
```

---

## Emergency Procedures

### "I broke main/develop!"
1. Don't panic
2. Notify Member 6 immediately
3. Member 6 reverts: `git revert <bad-commit-hash>` on affected branch
4. Team coordinates fix on feature branch

### "I need a hotfix on main!"
1. `git checkout main`
2. `git pull origin main`
3. `git checkout -b hotfix/critical-fix`
4. Fix, test, PR to main
5. After merge, backport to develop: `git checkout develop && git merge main`

---

## Quick Reference Card

| Action | Command |
|--------|---------|
| Start work | `git checkout develop && git pull && git checkout -b memberX/feature` |
| Save progress | `git add . && git commit -m "msg" && git push origin memberX/feature` |
| Sync with team | `git fetch origin && git rebase origin/develop` |
| Resolve conflict | Edit files → `git add .` → `git rebase --continue` |
| Ready for review | Push → Create PR → Tag Member 6 |
| After merge | `git checkout develop && git pull && git branch -d memberX/feature` |