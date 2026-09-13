# Batch Review Troubleshooting

## Playwright scoped to only storybook / one app

If the review says "I scoped the Playwright pass to storybook" or only visits one app — the review is wrong. Rule 16: Playwright must cover ALL apps, ALL routes. bugkid-web, clayton-web, AND storybook-web. `bun run dev` starts all of them. "The apps would need fresh dev servers with env vars" is false — env vars are present via `.env.local`. Re-run Playwright visiting every route in every app.

## Console warnings dismissed as "benign" or "non-blocking"

If the review treats console warnings (LCP hints, 404s, deprecation notices) as acceptable — the review is wrong. Rule 17: the standard is zero errors AND zero warnings. A favicon 404 is an error. An LCP hint is a warning. "Dev-only" and "benign" do not make them acceptable. Every route with console output is FAIL.

## Footnote or asterisk used to qualify PASS

If the review marks something as "clean\*" or "PASS†" with a footnote containing a caveat — the review is wrong. Rule 15: no footnotes, asterisks, or mechanisms to hide caveats on a PASS. If there's any caveat, it's FAIL. Remove the footnote system and mark the item FAIL with the issue listed.

## Open items or "flagged for later" lists

If the review creates an "Open Item" list, or says something is "flagged so it isn't missed" — the review is wrong. Rule 18: there are no open items. Every item is resolved or FAIL. Do not create tracking lists. Do not defer issues into future phases. Fix it now or ask the user.

## Review output uses deferral language ("later", "non-critical", "pre-existing")

This is the most common failure mode. If the review output contains ANY of these phrases, the review itself is wrong:

- "can clean up later", "non-critical", "follow-up"
- "pre-existing", "out of scope", "not introduced by this PR"
- "we improved it", "better than main", "fewer errors than before"

The fix: re-run `/batch-review`. The hard rules at the top of the skill definition explicitly ban this language. If it still appears, the issue is that the AI is rationalizing around the rules — escalate to the user.

## Review marks items as PASS with caveats

A PASS with any caveat ("PASS — 2 dead files remain but non-critical") is actually a FAIL. There is no third state. If you see this in output, the review is invalid. The item should be marked FAIL and the issues listed for remediation.

## Review uses strikethrough or "FIXED" status

Items should never be ~~struck through~~ or marked "FIXED." If an issue was found and fixed during the review, re-run the check. The final output should show only the re-check result: PASS or FAIL. The history of what was found and fixed belongs in the remediation log, not the findings checklist.

## Review skips failing tests because they "fail on main too"

If the review says "tests have the same 5 failures on main — confirmed not introduced by this PR" and proceeds to the next step — the review is wrong. Test failures are not skippable. "Same failures on main" is deferral language (rule 7) and a comparative pass (rule 8). 5 failures on main + 5 failures on this branch = 5 failures = FAIL. Fix them. Do not proceed to build until tests pass with zero failures.

## Review suppresses errors instead of fixing them

If the review uses `@ts-ignore`, `@ts-expect-error`, `as any`, `as unknown`, `// eslint-disable`, empty catch blocks, or other suppression techniques — the error is not fixed, it's hidden. This violates rule 12. Suppression also includes "a different approach" that makes the error go away without understanding why it occurred. If the fix isn't obvious, the answer is deeper research (read library types, check versions, trace type chains, read docs), not suppression. Revert the suppression and investigate the root cause.

## Review starts fixing errors before completing the audit

If the review finds errors and immediately starts editing files, spawning agents, or committing fixes — it has broken Phase 1. Phase 1 is read-only. The full audit must complete before any code changes. On-the-fly fixes lack the full context: error A and error B might share a root cause, or fixing A might conflict with fixing B. The remediation plan in Phase 2 exists specifically to coordinate fixes with the complete picture. If this happens, discard the fixes, re-run `/batch-review` from scratch.

## Review rationalizes violations as "intentional patterns"

If the review says something like "these re-exports are an intentional app-level indirection pattern" or "this is by design" to justify a rule violation — the review is wrong. Hard rule 4: forbidden things are never intentional. The rules define what is acceptable. The reviewer does not get to override them with architectural judgment, design patterns, or explanations of why the violation is actually good. Re-run the review.

## Review says FAIL but then says "ready to merge"

This is the most dangerous failure mode. If ANY checklist item is FAIL, the output must NOT contain "ready to merge", "want me to merge it?", a merge order, or any suggestion that the PR can proceed. Hard rule 10: FAIL means STOP. If you see a FAIL followed by a merge recommendation, the review is invalid. The PR is blocked until all FAILs are resolved.

## Review says "none introduced by this PR" to justify errors

"None introduced by this PR" is banned language (rule 8). It does not matter who introduced the errors. If `tsc --noEmit` reports errors in the PR's packages, the PR has errors. 18 errors is 18 errors whether the PR introduced 0 of them or all of them. Fix to zero.

## Review reports fractional counts as passing (e.g., "11/13")

Any count where N < M is a FAIL. "11/13 re-exports have consumers" means 2 do not — that's 2 issues. The only passing count is M/M. If you see a fractional count marked as passing, the review is invalid. Fix the remaining items, then report the whole count.

## Review skipped a check

Every check must run on every PR. "N/A" is only valid when the check is structurally impossible (e.g., "Storybook: N/A — no component packages exist in this repo"). It is NOT valid for "probably fine", "simple PR", or "already looked at this." If a check was skipped, re-run the full review.

## Type errors dismissed because main has more

"Main has 20 errors, PR has 10, so we improved it" is a FAIL, not a PASS. The standard is zero errors in the PR's packages. If main has errors in those packages, the PR must fix them. This is non-negotiable per the hard rules.

## No PRs found

The skill looks for open PRs authored by the current git user. If none are found:

- Confirm PRs exist with `gh pr list --author @me`
- Check that `gh auth status` shows a valid session
- Ensure PRs are open, not draft-only filtered

## Agent worktrees branched from wrong base (stale base contamination)

The most common contamination source: the harness creates worktrees from main by default, but if work is happening on a feature branch, agents need to branch from that feature branch. A worktree branched from an old main commit will carry unrelated files in its diff. To detect: `git merge-base --is-ancestor <feature-branch-HEAD> <agent-branch>` — if false, the agent has a stale base. To prevent: every agent prompt must specify the exact branch to branch FROM and PR INTO. To fix: close the contaminated PR, salvage relevant files onto a clean branch from the correct base.

## False type/test failures after deps merge

If a PR that changes `package.json` or `bun.lock` was just merged, and the next validation step shows missing-module type errors or import failures — the cause is stale `node_modules`. Run `bun install` after any deps-changing merge, before running validation. This is not a "pre-existing error" — it's a stale environment.

## Contamination false positives

Shared config files (`tsconfig.json`, `package.json`, lock files) often appear in multiple PRs due to dependency changes. These are usually legitimate. The skill may flag them — use judgment on whether the change is intentional for that PR's scope.

## Dependency detection misses

The skill infers dependencies from file-level overlap and import analysis. It may miss:

- Runtime dependencies (e.g., a PR adds an API route another PR calls at runtime)
- Database migration ordering
- Shared environment variable additions

Review the merge sequence manually for these cases.

## Merge artifacts in generated files

Lock files (`bun.lock`, `package-lock.json`) may contain conflict markers after a bad rebase. These won't be caught by normal grep if the file is in `.gitignore`. Run `git diff --check` on each branch for a more thorough scan.

## Pre-existing error detection too aggressive

The phrase search may match legitimate uses like documentation or comments explaining historical context. The skill will flag all matches — dismiss those that are genuinely informational rather than excuse-making.

## Bug detection false positives

The skill may flag code patterns that look wrong but are intentional (e.g., a barrel import that works because a custom resolver is configured, or a seemingly missing null check guarded by an upstream validator). If you're confident the code is correct, dismiss the finding.

## Remediation plan creates too many new PRs

If the remediation plan suggests several new PRs for related issues, consider combining them. For example, if 4 PRs all have the same `@repo/core` module resolution error, one fix PR is better than four.

## Merge order says "blocked" but issues are already fixed

The skill checks the state at the time it runs. If you fixed issues after the review but before re-running, the old output is stale. Run `/batch-review` again to get an updated merge order.

## Remediation order doesn't match your priorities

The default priority (pre-existing errors → bugs → artifacts → contamination → superseded PRs) assumes errors may change the dependency graph. If you know they won't, reorder as needed — the priority is a recommendation, not a hard rule.

## Circular dependencies between PRs

If the skill reports circular dependencies, the batch likely produced entangled work. Options:

- Merge the circular PRs into a single branch
- Extract the shared dependency into its own PR and rebase both on top of it

## Reexport flagged but it's a legitimate barrel

The skill flags all reexports. If a barrel file is the intended public API for a package (e.g., `packages/ui/src/index.ts` exporting the package's public surface), that's fine — dismiss the finding. The rule targets reexports added to preserve old import paths after a move, not intentional package entry points.

## Playwright MCP not configured

If Playwright MCP is not configured as an MCP server, Phase 4 Step 6 and Phase 5 Step 7 cannot run. This is a FAIL — not "skipped." Tell the user Playwright MCP is required and halt until it is configured. Do NOT substitute manual assessment for Playwright verification.

## "Env vars not available" — they are

The `.worktreeinclude` file copies `.env.local` files into worktrees. If you claim env vars are "not available in this environment" and skip Playwright/Storybook/dev server steps — you are wrong. The env vars ARE available. Check that `.env.local` exists in the app directory. If it somehow doesn't exist, ask the user — don't skip. "Skipped — env vars not available" is a FAIL that you caused by not looking, not a legitimate infrastructure limitation.

## "221/224 tests pass" marked as PASS

Any test result with failures > 0 is FAIL. "221/224" is a fractional count (rule 14). The standard is 224/224. Do not present partial pass rates as PASS. Fix the failing tests.

## Validation steps were assessed instead of executed

If the review output says things like "Build: passed" without showing the actual command output, the validation was not done. Every step must show: the command that was run, the actual output, and PASS/FAIL based on that output. "I checked and it looks fine" is not execution. Run the command. Paste the output.

## Dev server won't start

If `bun run dev` fails, that is a FAIL on Phase 4 Step 6 before Playwright even starts. Fix the dev server error first, then re-run all steps.

## Playwright MCP can't reach a route (404, timeout)

If a route 404s or times out, check:

- Is the dev server running on the expected port?
- Does the route require authentication? (account pages may need a session)
- Is the route a dynamic segment that needs a real slug?

For auth-gated routes, note them as requiring manual verification — but do NOT skip them silently.

## Too many routes to visit

Visit all of them anyway. This is not optional. The deep dive exists specifically to catch issues that targeted checks miss. If it takes a long time, that's fine — thoroughness is the point.

## Skill doesn't appear as `/batch-review`

- Verify the file exists at `.claude/skills/batch-review/SKILL.md`
- Restart the Claude Code session — skills are discovered at session start
- Check that the frontmatter `name: batch-review` is present
