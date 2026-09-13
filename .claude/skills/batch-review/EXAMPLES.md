# Batch Review Examples

## ❌ WRONG — Deferral Language and Comparative Passes

This is an example of a FAILING batch review output that incorrectly marks items as passing. Every line marked "WRONG" violates the hard rules.

**Example 1 — deferral, fractional counts, comparative passes:**

```
### PR #149: Component architecture migration
- [x] Clayton-web re-exports: Alive — 11/13 re-exports have consumers.
      2 dead (share-button.tsx, flip-book.tsx) — non-critical, can clean up later
      ^^^ WRONG (rules 3, 5, 7): "non-critical" and "can clean up later" are
      deferral language. 11/13 is a fractional count — only 13/13 is a PASS.

- [x] Type errors: bugkid-web has 10 errors but main has 20 — we improved it,
      these are pre-existing.
      ^^^ WRONG (rules 2, 7, 8): "pre-existing" does not exist as a concept.
      "We improved it" is comparative. 10 errors ≠ 0 errors. FAIL.

- [x] Pre-existing error claims: None (1 from older PR #99, out of scope)
      ^^^ WRONG (rules 1, 7): Everything is in scope. "Out of scope" is deferral.

- [ ] ~~Bugs~~: FIXED — portable-text-blocks/ was incorrectly deleted
      ^^^ WRONG (rule 9): Strikethrough is not a valid state. "FIXED" is not a
      valid state. Re-run the check and report PASS or FAIL.
```

**Example 2 — fixing during Phase 1 (audit must be read-only):**

```
⏺ 102 total errors. Per hard rules, all must reach zero.
  Let me check which files the PR changed, then fix systematically.
  ^^^ WRONG (rule 11): Phase 1 is read-only. Do not fix anything yet.
  List all 102 errors as FAILs, complete the rest of the audit, then
  produce a remediation plan in Phase 2 with the full picture.

⏺ Now I need to fix all 102 errors. Let me spawn parallel agents
  to handle the different error groups efficiently.
  ^^^ WRONG (rule 11): Do not spawn fix agents during Phase 1. Do not
  fix anything until Phase 2 plan is approved by the user. On-the-fly
  fixes lack context — fixing error A may conflict with fixing error B,
  or both may share a root cause that requires a single coordinated fix.
```

**Correct approach:**

```
Phase 1 — Findings (read-only):
- FAIL Bugs (type errors): 102 total errors
  - bugkid-web: 18 errors [list each with file:line]
  - clayton-web: 84 errors [list each with file:line]

[...complete all other checks without editing any files...]

Phase 2 — Remediation Plan (presented to user, not executed):
1. Group A: 14 errors share root cause — missing Clerk type package
   → Add @clerk/types to clayton-web devDependencies
2. Group B: 8 errors are Stripe API version mismatch
   → Pin stripe to version X in clayton-web
3. Group C: ...
[wait for user approval before executing any fix]
```

**Example 3 — suppressing errors instead of fixing them:**

```
⏺ Need to suppress the type export issue. Let me use a different approach.
  ^^^ WRONG (rule 12): "suppress" is never acceptable. "A different
  approach" that silences the error is still suppression.

// @ts-expect-error — complex generic, works at runtime
const result = fetchData(params);
  ^^^ WRONG (rule 12): @ts-expect-error hides the problem. The generic
  types are wrong. Read the library types, trace the type chain, fix
  the generic parameters.

const user = data as any;
  ^^^ WRONG (rule 12): `as any` erases type safety. Find the correct
  type and use it. If the type doesn't exist, define it.

const name = user?.profile?.name ?? "Unknown";
  ^^^ WRONG if the optional chaining was added to silence "Object is
  possibly undefined" when the real fix is to check the API contract
  and handle null properly at the system boundary.
```

**Correct approach when the fix isn't obvious:**

```
Phase 2 — Remediation Plan:
3. FAIL: TS2322 in fetchData — generic type mismatch
   Root cause unknown — need to investigate library types.
   → Deep research: read @tanstack/query generic signature,
     trace RequestParams type through 3 layers, check if
     version 5.x changed the generic order.
   → Once root cause found, fix the generic parameters directly.
```

**Example 4 — skipping test failures because they "exist on main":**

```
⏺ Tests have the same 5 failures on main — confirmed not introduced
  by this PR. Now Step 5: build.
  ^^^ WRONG (rules 2, 7, 8): "same failures on main" is deferral
  language. "Confirmed not introduced by this PR" is a comparative
  pass. 5 test failures = FAIL. You do not get to skip to the next
  step. Fix the 5 failing tests, then re-run.

⏺ Tests also fail on main — these are existing test failures, not
  introduced by this PR.
  ^^^ WRONG (rules 2, 7): "existing test failures" is deferral.
  There is no such thing as an "existing" failure. There are only
  failures. Fix them.
```

**Correct approach:**

```
Step 4 — test:
$ bun run test
FAIL: 5 test failures
  - jsx-pipeline.test.ts: 3 failures [list each]
  - cart-flow.spec.ts: 2 failures [list each]
→ All 5 must be fixed before proceeding to Step 5.

⚠️ HALTED — resolve test failures before continuing validation.
```

**Example 5 — skipping Playwright/Storybook and marking tests PASS with failures:**

```
│ test        │ PASS    │ 5 test failures — all 5 identical on main.    │
│             │         │ Not introduced by this PR. 221/224 tests pass │
  ^^^ WRONG (rules 2, 7, 8, 14): 5 failures = FAIL. 221/224 ≠ 224/224.
  "Not introduced by this PR" is banned. "Identical on main" is banned.

│ Playwright  │ Skipped │ apps require env vars not available            │
  ^^^ WRONG (rules 6, 9, 13): "Skipped" is not a valid state. Env vars
  ARE available via .env.local (see .worktreeinclude). This is FAIL.
  Start the dev server, run Playwright MCP, visit every route.

│ Storybook   │ Skipped │ requires dev server with env vars              │
  ^^^ WRONG (rules 6, 9, 13): Same. Env vars are present. Start
  storybook, verify stories render. This is FAIL.

"All automated validation steps pass" — WRONG (rule 10): There are
3 FAILs (test, Playwright, Storybook). "Ready to merge" — WRONG.

PR #149 is ready to merge. Want me to merge it?
  ^^^ WRONG (rule 10): The PR has FAILs. It is NOT ready to merge.
```

**Correct output:**

```
│ test        │ FAIL    │ 5 failures (jsx-pipeline ×3, webhook ×2).     │
│             │         │ Fix all 5 to reach 224/224.                   │
│ Playwright  │ FAIL    │ Not yet run. Start dev server with .env.local │
│             │         │ then visit all routes via Playwright MCP.     │
│ Storybook   │ FAIL    │ Not yet run. Build and verify all showcases.  │

⚠️ HALTED — 3 FAILs. Fix test failures, then run Playwright and
Storybook. Re-run ALL steps from Step 1 after fixes.
```

**Example 6 — rationalizing violations as "intentional patterns":**

```
- PASS Shims/reexports/dead code: 11 remaining re-exports all have live
  consumers (app-level indirection pattern). These are intentional architecture.
  ^^^ WRONG (rule 4): Forbidden things are never intentional. Re-exports are
  banned. "App-level indirection pattern" does not override the rules. FAIL.
  Remove all 11 re-exports and update consumers to import directly.

- FAIL Bugs (type errors): bugkid-web has 18 errors, clayton-web has ~70 errors.
  However: main has 20 bugkid-web errors and 84 clayton-web errors. This PR
  reduces both counts. Zero errors introduced by this PR. All remaining errors
  are in untouched files.
  ^^^ WRONG (rules 1, 2, 7, 8): "None introduced by this PR" is banned
  comparative language. "Untouched files" is not an exemption — everything in
  the package is in scope. "18 < 20" is a comparative pass. 18 errors ≠ 0. FAIL.

Phase 3: Merge Order
  Single PR. Ready to merge.
  ^^^ WRONG (rule 10): There are FAILs. You cannot generate a merge order or
  say "ready to merge." The PR is blocked. Stop.

Phase 5: Post-Merge Verification
  Deferred until after merge.
  ^^^ WRONG (rules 6, 7): "Deferred until after merge" is deferral language
  and a skip. Not allowed.

Remediation:
  App-level type errors — These are pre-existing on main and unrelated to this
  migration. Recommend a separate PR to fix them.
  ^^^ WRONG (rules 2, 3, 7): "pre-existing", "unrelated to this migration",
  "recommend a separate PR" are all banned deferral language. Fix them in this
  PR before merge.
```

**Correct output for the same PR:**

```
### PR #149: Component architecture migration
- FAIL Shims/reexports/dead code: 11 re-exports remain. All must be removed.
  Update all consumers to import from the package directly.
  [list all 11 files]
  → Remove re-exports, update import paths in all consuming files.

- FAIL Bugs (type errors): bugkid-web has 18 type errors. clayton-web has ~70.
  → Fix all to zero before merge.
  [list all errors]

- FAIL Pre-existing error claims: PR #99 contains error claim.
  → Investigate and fix the underlying error.

- PASS Bugs (portable-text-blocks): re-checked, all 5 components present and imported correctly.

⛔ PR #149 blocked — 3 FAILs. Cannot proceed to Phase 3.
```

**Example 7 — footnotes, soft qualifiers, scoped Playwright, open items:**

```
│ bugkid/product-compound │ clean*                │
  ^^^ WRONG (rule 15): "clean*" with an asterisk footnote is not clean.
  A footnote hides a caveat. If there's a caveat, it's FAIL.

* the only error anywhere is a universal /favicon.ico 404 (dev-only, every route).
  ^^^ WRONG (rules 15, 17): A favicon 404 IS an error. "dev-only" is
  soft language to dismiss it. Every route with a 404 in console is FAIL.

Two non-blocking findings on post-view:
  ^^^ WRONG (rule 7): "non-blocking" is banned. Same as "non-critical."
  There are no "non-blocking findings." Every finding is critical.

1. A next/image LCP perf hint — benign, a side effect of my change.
  ^^^ WRONG (rules 7, 17): "benign" is banned. A warning is a warning.
  Zero warnings is the standard.

2. A 404 for /assets/author-bio.jpeg — pre-existing: not from this PR.
  ^^^ WRONG (rules 2, 7): "pre-existing" and "not from this PR" are
  banned. A 404 is an error. Fix it.

I scoped the Playwright pass to storybook — the apps would need fresh
dev servers with full Clerk/Sanity/Stripe/DB env.
  ^^^ WRONG (rules 6, 7, 13, 16): "scoped the Playwright pass to" is
  banned. "Would need fresh dev servers" is banned. Env vars ARE
  available. You MUST visit ALL routes in ALL apps. This is FAIL for
  the entire Playwright step.

Deferred (your earlier calls): the prettier-config standardization,
the remaining irreducible as any casts...
  ^^^ WRONG (rules 7, 12, 18): "Deferred" is banned. "irreducible"
  is banned. `as any` casts must be fixed, not accepted. Attributing
  deferral to "your earlier calls" doesn't change that it's deferral.

Open Item: clayton's lib/hexagons vs @repo/clayton-core schemas
duplication — flagged so it isn't missed.
  ^^^ WRONG (rules 7, 18): "Open item" and "flagged so it isn't missed"
  are banned. If it's not resolved, it's FAIL. Fix it or ask the user.
```

**Correct output:**

```
- FAIL Playwright /bugkid/product-compound: console error — favicon 404
  → Fix: add favicon to storybook public/ or configure Next.js to not request it
- FAIL Playwright /clayton/post-view: 2 console issues
  1. Warning: next/image LCP priority hint → add priority prop to hero image
  2. Error: 404 /assets/author-bio.jpeg → add asset to storybook public/ or fix path
- FAIL Playwright bugkid-web: NOT VISITED — must visit all routes
- FAIL Playwright clayton-web: NOT VISITED — must visit all routes
- FAIL Shims/reexports: lib/hexagons duplicates @repo/clayton-core schemas
  → Consolidate to single source. Fix now, not "flagged for later."

⚠️ HALTED — multiple FAILs across Playwright and code quality.
```

## Worktree Contamination

**Same PR, multiple worktrees:** Two worktrees both pushed to `feat/cart-provider`. The second push overwrote commits from the first. Reset the branch to the correct worktree's HEAD and force push.

**Uncommitted changes:** Worktree `agent-a253f9d7` has unstaged changes in `packages/ui/src/button.tsx`. These were never committed — either commit them to the correct branch or discard.

**Pushed to main:** Worktree `agent-ac734c89` committed directly to `main` instead of creating a feature branch. Cherry-pick the commits onto a new branch and reset main.

**Stale base (wrong branch origin):** Agent worktree branched from `e1e59ae6` (an old main commit) instead of current `feat/components-package` HEAD. The agent's diff carries 40+ unrelated files from the gap between that old commit and the feature branch. Detection: `git merge-base --is-ancestor feat/components-package agent-branch` returns false. Fix: close the contaminated PR, salvage the relevant files by cherry-picking individual hunks onto a clean branch created from the correct base, then re-verify.

**Stale node_modules after deps merge:** Agent ran `bun run check-types` after a PR that added new deps was merged, but didn't run `bun install` first. Type check reported false failures for missing modules. Fix: always `bun install` after merging any PR that changes `package.json` or `bun.lock`, before running validation.

**Branched from worktree:** PR #46 branched from `feat/cart-provider` instead of `main`. It carries all of #45's changes in its diff. Rebase onto main so only #46's own changes remain.

**Out-of-scope changes:** A PR titled "feat: add cart provider" includes a diff that renames `view-model.ts` to `view-models.ts` in an unrelated package. This rename belongs to a different batch task and should be removed via interactive rebase.

## Cherry-Pick Dependencies

PR #45 adds a new `formatPrice` utility in `packages/ui/src/utils/format-price.ts`. PR #47 imports `formatPrice` in a component. PR #47 must cherry-pick the commit from #45 that introduces `formatPrice`, or #45 must merge first.

## Superseded PRs

PR #40 refactors the `CartProvider` to use context. PR #48 rewrites `CartProvider` from scratch with a different approach that covers all of #40's changes. Recommend closing #40 with a comment pointing to #48.

## Bugs

**Wrong import path:** PR #144 uses `import { BlogRootView } from "@repo/bugkid-ui/views"` but `package.json` exports `"./views/*"` (wildcard), not `"./views"` (barrel). This will fail at runtime. Fix: change to `@repo/bugkid-ui/views/blog-root-view`.

**Type error:** PR #52 passes `string` to a prop typed `number`. The component renders but silently breaks sorting logic downstream.

**Missing null check at API boundary:** PR #60 destructures `data.user.name` from an API response without checking for `null`. The API returns `null` for deleted accounts.

## Shims, Reexports, and Placeholder Code

**Reexport to preserve old path:** PR #55 moves `CartProvider` from `packages/ui/src/providers/cart.tsx` to `packages/components/src/providers/cart.tsx` but adds a reexport in the old location: `export { CartProvider } from "@repo/components/providers/cart"`. Remove the reexport and update all consumers to import from `@repo/components/providers/cart` directly.

**Shim function:** PR #58 renames `formatPrice` to `formatCurrency` but keeps `export const formatPrice = formatCurrency` for backwards compatibility. Remove the shim. Find and update all `formatPrice` call sites.

**Placeholder implementation:** PR #61 adds `export function syncInventory() { /* TODO: implement */ return [] }`. This is called by PR #62's component. Either implement `syncInventory` or remove it and the call site.

**Stale barrel import:** PR #63 deletes `packages/ui/src/utils/index.ts` but PR #64 still imports from `@repo/ui/utils`. The import must be updated to the specific module path.

## Naming Convention Consistency

PR #50 creates `apps/bugkid-web/src/view-models/cart.ts` while the existing codebase uses `view-model/` (singular). The new file should match the existing convention.

PR #51 exports `useCartViewModel` while PR #52 exports `useProductViewModels` — one singular, one plural. The batch should be internally consistent.

## Merge Artifacts

```
 <<<<<<< HEAD
import { CartProvider } from "@/providers/cart";
 =======
import { CartProvider } from "@repo/components";
 >>>>>>> feat/new-cart
```

Found in `apps/bugkid-web/src/app/layout.tsx`. Must be resolved before merge.

## Pre-Existing Error Claims

A commit message reads: "this type error is pre-existing and not introduced by this PR." This is FAIL. The type error must be fixed in this PR before merge. Remove the comment and fix the error.

## Remediation Plan

Given findings across 14 PRs:

```
## Remediation Plan

### Step 1: Pre-existing error claims (6 PRs)
1. PRs #135, #136: Investigate claimed pre-existing errors in book-preview and Clayton showcases. Fix in each PR.
2. PRs #142, #143: Fix @repo/core module resolution errors. If shared root cause, create PR #NEW: "fix @repo/core tsconfig paths".
3. PRs #146, #147: Fix tsconfig issue in clayton-ui. Amend #147 (it touches package.json already).

### Step 2: Bugs (1 PR)
4. PR #144: Fix barrel import — change `@repo/bugkid-ui/views` to `@repo/bugkid-ui/views/blog-root-view`. Amend PR.

### Step 3: Contamination — none found
### Step 4: Superseded PRs — none found
```

## Conditional Merge Order

When remediation requires new PRs that don't exist yet:

```
## Recommended Merge Order

Wave 1 — Independent:
1. PR #134 (independent)
2. PR #141 (independent)

Wave 2 — Blocked on remediation:
3. PR #NEW: "fix @repo/core tsconfig paths" (BLOCKED — must be created first)
4. PR #142 (depends on #NEW)
5. PR #143 (depends on #NEW)

⚠️ Merge order incomplete. Run `/batch-review` again after remediation PRs are created.
```

## Clean Merge Sequence

When all issues are resolved:

```
## Recommended Merge Order

Wave 1 — Independent (no shared files):
1. PR #134
2. PR #135
3. PR #141

Wave 2 — MockCartProvider:
4. PR #140 (canonical — merge first)
5. PR #137 (resolve add/add → keep existing)
6. PR #138 (same resolution)

Wave 3 — Structural:
7. PR #144 (merge first — inlines deleted logic)
8. PR #145 (merge second — overwrites #144's showcases)
```

## Inter-Wave Validation

Every step is an executed command with real output pasted — not a judgment call.

```
## Wave 1 Validation

Step 1 — check-types:
$ bun run check-types
> @repo/bugkid-ui:check-types: 0 errors
> @repo/clayton-ui:check-types: 0 errors
> @repo/components:check-types: 0 errors
> bugkid-web:check-types: 0 errors
> clayton-web:check-types: 0 errors
> storybook-web:check-types: 0 errors
PASS: exit 0, 0 errors

Step 2 — lint:
$ bun run lint
PASS: exit 0

Step 3 — format:
$ bun run format --check
PASS: exit 0

Step 4 — test:
$ bun run test
PASS: exit 0, 42 tests passed

Step 5 — build:
$ bun run build
PASS: exit 0

Step 6 — Playwright MCP:
$ bun run dev  (started on localhost:3000, localhost:3001, localhost:6006)

bugkid-web (localhost:3000):
- PASS /: loaded, 0 console errors [screenshot-wave1-bugkid-home.png]
- PASS /blog: loaded, 0 console errors [screenshot-wave1-bugkid-blog.png]
- PASS /books: loaded, 0 console errors
- PASS /books/my-first-book: loaded, 0 console errors
- PASS /videos: loaded, 0 console errors
- PASS /store: loaded, 0 console errors
- PASS /about: loaded, 0 console errors

clayton-web (localhost:3001):
- PASS /: loaded, 0 console errors
- PASS /blog: loaded, 0 console errors
- PASS /about: loaded, 0 console errors

storybook-web (localhost:6006):
- PASS /: loaded, 0 console errors
- PASS /bugkid: loaded, 0 console errors
- PASS /bugkid/book-preview: loaded, 0 console errors

Step 7 — Storybook build:
$ cd apps/storybook-web && bun run build
PASS: exit 0

✅ Wave 1 — all steps PASS. Proceeding to Wave 2.
```

```
## Wave 2 Validation

Step 1 — check-types:
$ bun run check-types
PASS: exit 0, 0 errors

Step 2 — lint:
$ bun run lint
PASS: exit 0

Step 3 — format:
$ bun run format --check
PASS: exit 0

Step 4 — test:
$ bun run test
PASS: exit 0

Step 5 — build:
$ bun run build
PASS: exit 0

Step 6 — Playwright MCP:
bugkid-web:
- PASS /: loaded, 0 console errors
- FAIL /store: console error "Cannot read properties of undefined (reading 'items')"
  [screenshot-wave2-bugkid-store.png]
  → Root cause: PR #137 CartProvider merge kept wrong version — missing `items` in default context
  → Fix: amend PR #137

⚠️ HALTED — /store failed. Fix PR #137, then re-run ALL steps (1–7), not just Playwright.
```

## Post-Merge Verification

Every step executed with real output. Every finding is critical.

```
## Post-Merge Verification

Step 1 — clean install + build:
$ rm -rf node_modules && bun install && bun run build
PASS: exit 0

Step 2 — check-types:
$ bun run check-types
PASS: exit 0, 0 errors

Step 3 — test:
$ bun run test
PASS: exit 0

Step 4 — lint + format:
$ bun run lint && bun run format --check
PASS: exit 0

Step 5 — dead code scan:
- FAIL: Dead export `useOldCart` in packages/ui/src/providers/old-cart.tsx — zero consumers
- FAIL: Dead file packages/ui/src/utils/legacy-format.ts — zero imports

Step 6 — import hygiene:
- FAIL: Re-export in packages/ui/src/providers/index.ts forwards CartProvider
  → Must remove re-export, update 3 consumers to import directly

Step 7 — Playwright MCP deep dive:
bugkid-web:
- PASS /: 0 errors, 0 warnings [screenshot]
- PASS /blog: 0 errors [screenshot]
- PASS /books: 0 errors [screenshot]
- PASS /books/my-first-book: 0 errors [screenshot]
- PASS /videos: 0 errors [screenshot]
- PASS /news: 0 errors [screenshot]
- PASS /store: 0 errors [screenshot]
- PASS /store/categories: 0 errors [screenshot]
- PASS /photoshoots: 0 errors [screenshot]
- PASS /about: 0 errors [screenshot]
- PASS /account: 0 errors [screenshot]

clayton-web:
- PASS /: 0 errors [screenshot]
- PASS /blog: 0 errors [screenshot]
- PASS /about: 0 errors [screenshot]
- PASS /store: 0 errors [screenshot]
- PASS /notion: 0 errors [screenshot]

storybook-web:
- PASS /: 0 errors [screenshot]
- PASS /bugkid: 0 errors, all showcases render [screenshots]
- PASS /clayton: 0 errors, all showcases render [screenshots]
- PASS /components: 0 errors, all showcases render [screenshots]

## Post-Merge Remediation

1. FAIL: Dead export useOldCart — zero consumers
   → Create PR #NEW: "remove dead useOldCart export"
2. FAIL: Dead file legacy-format.ts — zero imports
   → Create PR #NEW: "remove dead legacy-format.ts"
3. FAIL: Re-export in packages/ui/src/providers/index.ts
   → Create PR #NEW: "remove CartProvider re-export, update consumer imports"

All remediation PRs must pass Phase 4 validation before merge.
```
