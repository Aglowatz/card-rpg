---
name: batch-review
description: Post-batch review checklist for PRs — contamination, dependencies, naming, artifacts, sequencing
invocation: manual
---

# Batch Review

Review all open PRs authored by the current git user on this repo. Run each check below and report findings grouped by PR, then provide a final merge sequence.

## HARD RULES — NON-NEGOTIABLE

These rules override all other judgment. There are NO exceptions. Do not rationalize around them. Do not reinterpret them. Do not find creative workarounds. Follow them literally.

1. **Everything is in scope.** There is no "out of scope." If `tsc --noEmit` reports an error in a package the PR touches — regardless of which file, which line, who wrote it, or when — it is in scope and must be fixed. "Untouched files" is not an exemption. "Unrelated to this migration" is not an exemption. The package has errors. Fix them.

2. **No errors are pre-existing.** There is no such thing as a pre-existing error. Every error is just an error — type errors, test failures, lint errors, build errors, ALL of them. "None were introduced by this PR" is irrelevant — the errors exist, so the PR is not ready. "Tests have the same 5 failures on main — confirmed not introduced by this PR" is a rule violation. 5 test failures = FAIL. Fix them. "This PR made both apps better (18 < 20)" is a rule violation, not a defense. Fix all errors to zero.

3. **Everything is critical.** There is no "non-critical." There is no "separate effort." There is no "recommend a separate PR." Every issue found must be fixed before this PR merges. If fixing the issues is too much work for this PR, then this PR is too big — but the answer is never to defer the work.

4. **Forbidden things are never intentional.** Do not reclassify a rule violation as an "intentional architecture pattern," "app-level indirection," "design decision," or any other justification. If the rules say no re-exports and you find re-exports, that is a FAIL — not an "intentional pattern." The rules define what is acceptable. You do not get to override them with architectural judgment.

5. **All counts must be whole.** "11/13 re-exports have consumers" is a FAIL — 13/13 is the only PASS. Any fractional count (N/M where N < M) means unresolved issues remain. Do not present a partial count as a pass. Fix the gap, then report M/M.

6. **No skips.** Every check must be run. Every item must be evaluated. Every file must be examined. Do not skip a check because it "probably" passes, because the PR is "simple," or because you already fixed something. Run the check. Report the result. "Deferred until after merge" is a skip — not allowed. "Skipped — env vars not available" is a FAIL, not a skip. Env vars are available via `.env.local` files (see `.worktreeinclude`). If a step cannot run, it is FAIL — not "skipped." There is no "skipped" state. Only PASS or FAIL.

7. **No deferral language.** Never write or accept: "can clean up later", "non-critical", "out of scope", "pre-existing", "not introduced by this PR", "we improved it", "follow-up", "low priority", "separate effort", "separate PR", "unrelated to this migration", "recommend a separate PR to fix", "deferred until after merge", "same failures on main", "confirmed not introduced", "existing test failures", "non-blocking", "benign", "cosmetic", "informational", "minor", "scoped the Playwright pass to", "would need fresh dev servers", "irreducible", "dev-only", "open item", "flagged for later", "flagged so it isn't missed", or any other language that defers work, downgrades severity, reduces scope, or attributes failures to main. If you catch yourself writing deferral language, STOP — that item is a FAILURE, not a pass.

8. **No comparative passes.** "Better than main" is not a pass. "Fewer errors than before" is not a pass. "18 < 20" is not a pass. "None introduced by this PR" is not a pass. The only pass is zero issues. Compare against the standard (zero), not against the current state of main, not against what this PR introduced.

9. **Every checklist item is PASS or FAIL.** There is no third state. No "Skipped." No strikethrough-with-caveat. No "FIXED." No "DONE." No "N/A" on validation steps. No explanatory paragraphs justifying why a FAIL is actually okay. If an item has any issue remaining, it is FAIL. If a step could not run (missing env vars, server won't start, tool unavailable), it is FAIL — not "skipped." Period.

10. **FAIL means STOP.** A single FAIL on any checklist item means the PR cannot proceed to Phase 3. Do not generate a merge order. Do not say "ready to merge." Do not ask "want me to merge it?" The PR is blocked. Say so and stop. The only path forward is to fix every FAIL, re-run the checks, and get all PASS.

11. **Audit first, fix later.** Phase 1 is read-only. Do not edit files, commit changes, spawn fix agents, or modify code during Phase 1. Find ALL issues across ALL checks first. Then produce the remediation plan in Phase 2 with full context. Then STOP and wait for user approval. Only then execute fixes. Fixing on the fly produces blind fixes that conflict with each other or miss the bigger picture.

12. **Fix errors, never suppress them.** Never use `@ts-ignore`, `@ts-expect-error`, `as any`, `as unknown`, `// eslint-disable`, `type: "module"` hacks, empty catch blocks, optional chaining to silence a type error, or any other technique that makes an error disappear without fixing the root cause. If the fix is not obvious, that means you need to do deeper research — read the library's types, check the package version, trace the type chain, read documentation. "Suppress" is never the answer. "A different approach" that silences the error instead of fixing it is suppression with extra steps.

13. **Env vars are available. Use them.** The `.worktreeinclude` file ensures `.env.local` files are present in worktrees. The dev server, Playwright, and Storybook steps require env vars — they are there. Do not claim env vars are "not available in this environment" to skip Playwright or Storybook. If the dev server fails to start, debug why — read the error, check the `.env.local` files exist, check the ports. "Env vars not available" is not a valid reason to skip. It is a problem to solve.

14. **221/224 is not PASS.** Any test result where failures > 0 is FAIL. "221/224 tests pass" means 3 failed. That is FAIL. Do not present a fraction of passing tests as a PASS. The standard is 224/224 — every test passes, zero failures.

15. **No footnotes, asterisks, or soft qualifiers.** Do not use `*`, `†`, footnotes, parenthetical asides, or any mechanism to attach caveats to a PASS. "clean\*" is not clean — it is FAIL with a hidden caveat. Do not invent new finding categories like "non-blocking findings," "benign," "informational," "cosmetic," or "minor." Every finding is either an issue (FAIL) or not present (PASS). Do not use soft language to downgrade the severity of a finding.

16. **Playwright must cover ALL apps, ALL routes.** Phase 4 Step 6 requires visiting every route in every app — bugkid-web, clayton-web, AND storybook-web. You may not "scope" Playwright to only the apps you changed or only storybook. "The apps would need fresh dev servers" is not an excuse — `bun run dev` starts them all. "I scoped the Playwright pass to storybook" is a rule violation. Visit every route listed in Phase 4 Step 6. No exceptions. No partial coverage.

17. **Zero errors AND zero warnings.** The browser console standard is zero errors AND zero warnings. A 404 is an error. An LCP hint is a warning. A hydration mismatch is an error. A favicon 404 is an error. "Only a favicon 404" is still a 404 = FAIL. "Benign LCP hint" is still a warning = FAIL. If the console has any output classified as error or warning, that route is FAIL.

18. **No open items.** There is no such thing as an "open item," "flagged for later," "Phase B.5," or "flagged so it isn't missed." Every item is either resolved NOW or it is a FAIL that blocks merge. Do not create tracking lists of things to address later. Do not "flag" issues — fix them or mark the check FAIL. If you aren't sure how to resolve something, ask the user — do not defer it into a future phase.

19. **Self-check.** Before finalizing your output, re-read rules 1–18. Search your own output for: every banned phrase from rule 7; comparative language from rule 8; fractional counts from rule 5; suppression patterns from rule 12; "skip" or "skipped"; "not introduced"; "ready to merge" when any FAIL exists; asterisks or footnote markers qualifying a PASS; "non-blocking", "benign", "cosmetic", "minor"; "scoped to" or "scoped the Playwright"; "irreducible"; "open item" or "flagged"; any Playwright validation that doesn't explicitly cover all three apps. If you find a violation in your own output, you have failed — fix your output before presenting it.

## 1. Worktree Contamination

Check every worktree and its associated PR/branch for contamination. Contamination means any of the following:

- Multiple worktrees pushed commits to the same PR branch
- A worktree has uncommitted or unstaged changes left behind
- A worktree pushed directly to main
- A worktree branched from another worktree's branch instead of main
- A worktree branched from a stale base commit (e.g., an old main commit instead of the current feature branch HEAD). Verify: `git merge-base --is-ancestor <feature-branch-HEAD> <worktree-branch>` — if the feature branch HEAD is NOT an ancestor of the worktree branch, the worktree has a stale base and its diff will carry unrelated changes or miss recent work.
- A worktree cherry-picked or includes changes from a different scope (files/hunks that belong to a different batch task)
- A PR diff contains changes outside the stated purpose of that PR
- A worktree's `node_modules` is stale after a deps-changing merge (missing packages will cause false build/type/test failures). After merging any PR that touches `package.json` or `bun.lock`, run `bun install` before running validation.

For each contamination found, identify the source and recommend corrective action (interactive rebase, branch reset, force push, etc.).

**Prevention (for agents spawned during remediation):** When spawning worker agents to fix issues, every agent prompt MUST include:

1. The exact branch to branch FROM (not main — the feature branch, by name)
2. The exact branch to PR INTO (the feature branch, not main)
3. Instruction to run `bun install` before any validation
4. Instruction to verify their base is current: `git log --oneline -1 <feature-branch>` must match their merge-base

If an agent's prompt does not include these 4 items, the agent will contaminate. This is a known root cause — the harness defaults to creating worktrees from main, which produces stale-base contamination.

## 2. Cherry-Pick True Dependencies

Identify PRs that depend on changes from other PRs (shared files, type imports, new exports consumed by another PR). For each dependency found, recommend cherry-picking the dependency into the dependent branch.

## 3. Close Superseded PRs

If a newer PR fully replaces or subsumes an older one, recommend closing the older PR with a comment explaining why.

## 4. Bugs

Review each PR's diff for correctness issues:

- Incorrect imports (wrong paths, barrel imports where specific paths are required, missing exports)
- Type errors — run `bun run check-types`. The result must be **zero errors** across ALL packages. Not "fewer than main." Not "zero in packages we touched." Zero everywhere. If any package has errors, fix them in this PR.
- Runtime bugs (wrong variable, missing null check at a system boundary, broken logic)
- Any other code defect introduced by the batch

## 5. No Shims, Reexports, or Placeholder Code

Every PR must contain final, working code. Flag and reject:

- **Reexports** — barrel files or re-export statements added to preserve old import paths. Update all consumers to use the correct import path directly.
- **Shims / compatibility layers** — wrapper functions, adapter modules, or renamed-but-forwarded exports. Remove the shim and update all call sites.
- **Placeholder code** — stub implementations, `// TODO` markers standing in for real logic, empty function bodies, or hardcoded mock data in non-test files. Replace with the real implementation or remove.
- **Stale imports** — every `import` statement must resolve to an existing, correctly-pathed module. No dead imports left over from refactors.
- **Dead exports/files** — if a file or export has zero consumers, remove it. Do not mark it as "non-critical" or "can clean up later." Zero consumers = delete now.

## 6. Naming Convention Consistency

Check that new files/folders/exports introduced by the batch follow existing conventions in the same directory. Flag:

- Singular vs plural mismatches (`view-model` vs `view-models`, `use-case` vs `usecases`)
- Kebab vs camel vs snake inconsistencies within the same domain
- File/folder naming that diverges from existing conventions in the same directory
- Inconsistencies introduced _between_ batch PRs (one PR uses one convention, another uses a different one)

## 7. Merge Artifacts

Search all tracked files for conflict markers: `<<<<<<<`, `>>>>>>>`, `=======`. These must be resolved before merge.

## 8. Pre-Existing Error Claims

Search code comments, commit messages, PR descriptions, and YOUR OWN OUTPUT for phrases like "pre-existing", "pre existing", "already broken", "existing issue", "not introduced by this PR", "out of scope", "can clean up later", "non-critical", "follow-up", or "we improved it". These are not acceptable — every one is a FAIL.

This applies to errors from ANY source — including older PRs, main branch, or other contributors. If the error exists in code this PR touches or depends on, it must be fixed before merge. "Another PR introduced it" does not matter. "It was already there" does not matter. Fix it or create a prerequisite PR that fixes it and merges first.

## 9. Sequence PRs in Merge Order

Based on the dependency analysis from step 2, output a recommended merge order:

- Independent PRs first (no dependencies on other batch PRs)
- Dependent PRs after their dependencies
- Flag any circular dependencies as blockers

## Output

The output has five phases. Do NOT skip ahead — each phase gates the next.

**CRITICAL: Phase 1 is READ-ONLY. Do not fix, edit, commit, amend, or spawn agents to fix anything during Phase 1.** Phase 1 is a complete audit. You must finish finding ALL issues across ALL checks across ALL PRs before touching any code. Fixing on the fly means you lack full context — a fix to one error may conflict with or duplicate a fix needed for another. The remediation plan in Phase 2 requires the complete picture. Collect everything first, then plan, then execute.

### Phase 1: Findings

**DO NOT EDIT ANY FILES DURING THIS PHASE.** Read, grep, run type checks, analyze diffs — but change nothing. If you find yourself about to fix something, STOP. Write it down as a FAIL and keep auditing.

Report findings grouped by PR. Every checklist item must be **PASS** or **FAIL** — no other states. No strikethroughs, no "FIXED", no custom items, no caveats on a PASS.

- PASS means zero issues found. Zero.
- FAIL means issues exist. List every issue with file paths and line numbers. Do not fix them yet.

```
### PR #N: <title>
- PASS | FAIL Worktree contamination: ...
- PASS | FAIL Dependencies: ...
- PASS | FAIL Bugs (including type errors — must be 0): ...
- PASS | FAIL Shims/reexports/dead code: ...
- PASS | FAIL Naming consistency: ...
- PASS | FAIL Merge artifacts: ...
- PASS | FAIL Pre-existing error claims / deferral language: ...
```

**A single FAIL blocks the PR from proceeding to Phase 3.**

### Phase 2: Remediation Plan

**DO NOT EDIT ANY FILES DURING THIS PHASE.** Phase 2 produces the plan. Phase 2 does NOT execute it. Present the complete plan to the user and WAIT FOR APPROVAL before changing any code.

After all findings from Phase 1, output an ordered remediation plan with full context from the entire audit. Because you completed Phase 1 without fixing anything, you now have the complete picture — use it to identify shared root causes, group related fixes, and avoid conflicting changes.

Address issues in this priority:

1. **Pre-existing error claims** — Investigate every claimed "pre-existing" error. Fix them in the originating PR or create a new dedicated PR. These come first because they may reveal real bugs that change the dependency graph.
2. **Bugs** — Fix any bugs found (incorrect imports, type errors, runtime issues, naming convention violations, wrong export paths, etc.). Amend the originating PR or create a new PR.
3. **Shims/reexports/placeholders** — Remove all reexports, shims, and placeholder code. Update all import paths to point directly to the correct module.
4. **Merge artifacts** — Resolve any conflict markers.
5. **Contamination** — Clean up contaminated worktrees/branches.
6. **Superseded PRs** — Close with comments.

For each remediation step, specify:

- Which PR(s) are affected
- What exactly needs to change (file paths, line numbers, the specific fix)
- Whether to amend an existing PR or create a new one
- Whether this fix depends on or conflicts with another fix in the plan

**After presenting the remediation plan, STOP and ask the user for approval.** Do not proceed to fix anything until the user confirms the plan.

### Phase 2b: Remediation Execution

Only after the user approves the Phase 2 plan, execute the fixes in the order specified. For each fix:

- Make the change
- Verify it locally (does the specific error disappear?)
- Do NOT re-run the full validation suite yet — that happens in Phase 4
- Commit with a clear message describing what was fixed and why

After all fixes are applied, re-run every Phase 1 check to confirm all items now PASS. If any still FAIL, return to Phase 2 — produce an updated remediation plan for the remaining issues and get approval again. Do not proceed to Phase 3 until every check is PASS.

### Phase 3: Merge Order (conditional)

Generate the merge order ONLY if all issues from Phase 2 are resolved or have a clear remediation path.

- If remediation requires **new PRs**, include them as placeholder slots: `PR #NEW: "fix @repo/core module resolution" (BLOCKED — must be created first)`
- If remediation requires **amending existing PRs**, note which ones need re-review after amendment
- Independent PRs first, dependent PRs after their dependencies
- Group PRs into merge waves — each wave is a set of independent PRs that can merge in parallel
- Flag circular dependencies as blockers

If there are unresolved issues that make the merge order unreliable, state: **"Merge order blocked. Run `/batch-review` again after remediation is complete."**

### Phase 4: Inter-Wave Validation

After each merge wave completes, you MUST execute every validation step below. These are commands to RUN, not checklist items to assess. Execute each one, paste the real output, and report PASS (zero errors) or FAIL (any errors). Do not skip any step. Do not summarize — show the actual output.

**Any failure halts the merge process. Do not proceed to the next wave.**

#### Step 1: Type check

```bash
bun run check-types
```

Must exit 0 with zero errors across ALL packages. Not just the packages the wave touched — ALL packages. If any package has errors, FAIL.

#### Step 2: Lint

```bash
bun run lint
```

Must exit 0. Any lint error is a FAIL.

#### Step 3: Format check

```bash
bun run format --check
```

Must exit 0. Any unformatted file is a FAIL. If it fails, run `bun run format` to fix, commit the result, and re-check.

#### Step 4: Test

```bash
bun run test
```

Must exit 0 with zero test failures. Any test failure is a FAIL — do not check whether the same test fails on main. Do not skip failing tests. Do not say "these are existing test failures." 5 test failures on main + 5 test failures on this branch = 5 test failures = FAIL. Fix them.

#### Step 5: Build

```bash
bun run build
```

Must exit 0. Any build error is a FAIL. Check output for warnings about unresolved imports — those are also FAIL.

#### Step 6: Dev server + Playwright MCP

Start the dev server and use Playwright MCP to verify every route the wave touched, plus all core routes.

```bash
bun run dev
```

Then use Playwright MCP to visit **ALL routes in ALL three apps.** You MUST visit all three apps — bugkid-web, clayton-web, AND storybook-web. Do not "scope" Playwright to only one app. Do not claim other apps "would need" env vars — `bun run dev` starts them all with `.env.local` present.

1. **Navigate to every route in every app:**
   - bugkid-web: `/`, `/blog`, `/books`, `/videos`, `/news`, `/store`, `/store/categories`, `/photoshoots`, `/about`, `/account`
   - clayton-web: `/`, `/blog`, `/about`, `/store`, `/notion`
   - storybook-web: `/`, `/bugkid`, `/clayton`, `/components`, and click into EVERY showcase within each
2. **For each route, check:**
   - Page loads without error (no white screen, no error boundary)
   - Browser console has **zero errors AND zero warnings** (use `browser_console_messages`). A 404 is an error. An LCP hint is a warning. A favicon 404 is an error. There is NO category of acceptable console output. If the console has anything, the route is FAIL.
   - No hydration mismatches in console
   - Key UI elements render (headers, navigation, content areas)
   - Interactive elements respond (click buttons, open menus, test navigation links)
3. **For routes with dynamic segments** (e.g., `/books/[slug]`), navigate to at least one real instance.
4. **Screenshot every route** using `browser_take_screenshot` for the record.

Report each route as PASS or FAIL with the console output and screenshot. If ANY route in ANY app is not visited, the entire Playwright step is FAIL.

#### Step 7: Storybook (if component packages were touched)

```bash
cd apps/storybook-web && bun run build
```

If storybook builds, also start it and use Playwright MCP to visit:

- `/bugkid` and click into each showcase
- `/clayton` and click into each showcase
- `/components` and click into each showcase

Verify every story renders without console errors.

#### On any FAIL:

- **HALT** — do not proceed to the next wave
- Identify the root cause
- Fix it (amend the PR or create a fix PR)
- Re-run ALL validation steps from Step 1 — not just the one that failed
- Do not proceed until every step is PASS

```
## Wave 1 Validation
- PASS check-types: exit 0, 0 errors (paste output)
- PASS lint: exit 0 (paste output)
- PASS format: exit 0 (paste output)
- PASS test: exit 0, N tests passed (paste output)
- PASS build: exit 0 (paste output)
- PASS Playwright /: loaded, 0 console errors [screenshot]
- PASS Playwright /blog: loaded, 0 console errors [screenshot]
- FAIL Playwright /cart: console error "CartProvider not found" [screenshot]
  → Root cause: PR #140 MockCartProvider not wired into layout
  → Fix: amend PR #140

⚠️ HALTED — re-run all steps after fix before proceeding to Wave 2
```

### Phase 5: Post-Merge Verification

After ALL waves have merged and passed Phase 4, execute a final comprehensive verification. You MUST run every step below. These are commands to EXECUTE, not items to assess.

#### Step 1: Clean install + full build

```bash
rm -rf node_modules && bun install && bun run build
```

Must exit 0. This catches dependency issues masked by stale node_modules.

#### Step 2: Full type check

```bash
bun run check-types
```

Must be zero errors across every package. This is the final confirmation.

#### Step 3: Full test suite

```bash
bun run test
```

Must exit 0.

#### Step 4: Lint + format

```bash
bun run lint && bun run format --check
```

Must exit 0.

#### Step 5: Dead code scan

Manually check for:

- Exports with zero consumers (grep for the export name across the repo — if nothing imports it, delete it)
- Files with zero imports (if nothing references the file, delete it)
- Duplicate declarations (two files providing the same utility with different names)

Every dead export/file found is a FAIL. Fix before proceeding.

#### Step 6: Import hygiene

Grep the entire codebase for re-exports, shims, and barrel files that shouldn't exist. Every re-export found is a FAIL (unless it is the package's public entry point in package.json `exports`).

#### Step 7: Playwright MCP deep dive

Start the dev server. Use Playwright MCP to visit EVERY route in EVERY app — not just affected routes, ALL of them:

**bugkid-web** — visit every page route:
`/`, `/blog`, `/books`, `/books/[any-slug]`, `/videos`, `/news`, `/store`, `/store/categories`, `/photoshoots`, `/photoshoots/[any-slug]`, `/about`, `/account`

**clayton-web** — visit every page route:
`/`, `/blog`, `/about`, `/store`, `/notion`

**storybook-web** — visit every showcase:
`/`, `/bugkid`, `/bugkid/[every-slug]`, `/clayton`, `/clayton/[every-slug]`, `/components`, `/components/[every-slug]`

For EACH route:

1. `browser_navigate` to the URL
2. `browser_console_messages` — must be zero errors and zero warnings
3. `browser_snapshot` — verify key elements are present
4. `browser_take_screenshot` — save for record
5. Click all interactive elements (navigation links, buttons, toggles, forms)
6. Check that navigation between routes works (click a link, verify destination loads)

For dynamic routes, visit at least 2 real instances each.

Report every route as PASS or FAIL.

#### Post-merge findings

Collect ALL issues into a remediation plan. Every issue is critical — there is no "non-critical" tier.

```
## Post-Merge Remediation

1. FAIL: /cart route throws "CartProvider not found"
   → Create PR #NEW: "fix CartProvider import in cart route"
2. FAIL: Dead export useOldCart in packages/ui — zero consumers
   → Create PR #NEW: "remove dead useOldCart export"
3. FAIL: Duplicate formatPrice in packages/ui and packages/components
   → Create PR #NEW: "consolidate formatPrice into @repo/components"

All remediation PRs must pass the same Phase 4 validation before merge.
```
