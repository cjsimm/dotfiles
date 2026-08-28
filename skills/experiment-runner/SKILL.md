---
name: experiment-runner
description: Execute one manager-provisioned, isolated code experiment through briefing, user-approved patch and evaluation gates, evidence capture, and a structured completion handoff. Use only when explicitly invoked for an approved run; do not use for ordinary implementation, generic testing, or informal experimentation.
---

# Experiment Runner

Conduct exactly one approved experimental run inside the dedicated Git worktree supplied by First Mate. Preserve the plan, implementation, evaluation, evidence, and report as one portable bundle without writing to the manager-owned collection archive.

Use `experiment-protocol/v1` for manager-to-runner and runner-to-manager messages. Use `experiment-run-bundle/v1` for the bundle manifest. A missing or mismatched version requires `HUMAN_TRIAGE_REQUIRED`; do not guess compatibility.

## Operating boundaries

- Start in briefing-only mode. Read and discuss, but do not change product code or run substantive evaluation until the user explicitly approves the final run plan.
- Treat the launch prompt as run-specific authority and this skill as reusable behavior. Never invent a baseline, identity, path, approval, command, service, cost allowance, retry allowance, or archive authority.
- Treat each semantic gate as user-owned. First Mate may supervise routine work and relay an explicitly attributed user decision, but may not approve a gate itself.
- Work only in the supplied branch and worktree. Preserve unrelated changes and do not merge, cherry-pick, publish, consolidate, delete a worktree, or edit collection-level documents.
- Implement the smallest intervention that can test the approved hypothesis. Avoid unrelated cleanup, refactoring, production hardening, fixture repair, and evaluation-specific overfitting.
- Report negative, inconclusive, invalid, failed, and abandoned outcomes accurately. A completed execution is not evidence that its hypothesis succeeded.

## Required launch contract

Before implementation, obtain and verify:

- protocol version, bundle format, collection ID, experiment ID, immutable run ID, and current phase;
- repository, exact origin commit, dedicated branch, absolute worktree, and supervising First Mate identity or pane;
- exact run directory beneath that worktree and the `experiment-run-bundle/v1` format;
- initial plan path or complete initial plan, hypothesis, scope, non-goals, and expected implementation area;
- approved model and reasoning effort;
- permitted commands, tools, services, data access, credentials boundaries, and routine approval authority;
- runtime, cost, concurrency, retry, and stopping limits;
- human-owned gates, decision criteria, approval-receipt fields, approval-relay convention, required artifacts, terminal handoff fields, and disposition options; and
- baseline source and comparison method, including who provisions a separate baseline worktree when one is required.

If an essential field is absent or inconsistent, remain in briefing mode and request a corrected launch contract through First Mate. Read [protocol v1](references/protocol-v1.md) before validating launch inputs, emitting any signal, or interpreting an approval.

## Non-negotiable bundle boundary

The complete run bundle must remain inside the supplied worktree. The plan, manifest, patch, report, configs, outputs, and artifacts must all resolve beneath the exact run directory. Do not put bundle content in the main checkout, sibling worktrees, the manager archive, `/tmp`, a home-directory cache, or another external path. Do not use symlinks or traversal to escape the boundary.

Resolve and check the real worktree and run-directory paths during briefing, before evaluation, and before completion. Treat an escaping path or symlink as `HUMAN_TRIAGE_REQUIRED`. Direct every approved command's durable outputs into the run bundle.

Remote services may retain source records when approved. Export evidence into the bundle when possible; otherwise record stable remote identifiers, access assumptions, retention risk, and the resulting reproducibility limitation. Never capture credentials or secrets in snapshots or artifacts.

Read [run bundle contract](references/experiment-run-bundle-v1.md) when creating the run directory, freezing provenance, recording retries, or finalizing `RUN_MANIFEST.json`.

## Lifecycle

### 1. Brief and freeze the plan

Read repository instructions and inspect only enough code and configuration to verify the plan's assumptions. Confirm the identity, origin, branch, worktree, bundle boundary, hypothesis, intervention, scope, non-goals, expected evidence, risks, and autonomy envelope.

During First Mate's interactive-takeover phase, discuss ambiguities with the user and record only explicitly agreed amendments in the in-worktree `EXPERIMENT_PLAN.md`. Present the reconciled plan and pause. Do not interpret silence, routine command approval, or collection approval as execution approval.

When the user explicitly approves execution, record a complete approval receipt bound to the plan freeze reference and freeze `EXPERIMENT_PLAN.md`. Do not rewrite it to match later outcomes. Record deviations in `REPORT.md`; a material change to the hypothesis or intended intervention normally requires a new run.

### 2. Construct and present the patch

Implement only the approved causal intervention. Do not change datasets, evaluators, graders, metrics, fixtures, or success criteria unless they are the approved subject of the experiment. A minimal smoke check is permitted only when the plan or autonomy envelope allows it and it establishes that the patch can execute; do not begin substantive evaluation.

Generate `implementation.patch` against the recorded origin, including every behavior-relevant added, modified, deleted, or binary file while excluding the run bundle itself. Assign a monotonically increasing patch revision and a SHA-256 digest to the exact patch. Emit `PATCH_REVIEW_REQUIRED` with the required packet, then pause.

User-requested revisions before substantive evaluation may remain in this run when they preserve the approved hypothesis and intervention. Each produces a new patch revision, digest, and handoff. Patch approval binds only the identified revision and digest. Confirm that the current implementation still matches the approved patch immediately before evaluation; any behavior-changing difference invalidates patch and evaluation approval.

### 3. Propose the evaluation

After patch approval, write an exact evaluation proposal covering baseline and treatment conditions, commands, cases, datasets, samples, controls, metrics, decision criteria, repetitions, concurrency, output paths, targeted checks, runtime, model usage, external cost, retry allowance, and validity risks.

Prefer direct evidence from the relevant end-to-end path or evaluation harness. Do not run broad PyTest suites by default. Use targeted tests only when they show that the patch is active or the relevant functional path works. Record incidental failures without repairing them unless they prevent target execution, corrupt evidence, or make baseline and treatment incomparable.

Assign an evaluation revision and SHA-256 digest to the proposal. Emit `EVALUATION_REVIEW_REQUIRED`, then pause. A proposal revision before substantive execution may remain in this run, but it requires a new revision, digest, handoff, and user decision. Evaluation approval binds only that evaluation revision and digest together with the current approved patch identity.

Do not switch the treatment worktree between origin and patched states to manufacture a baseline. Use the approved harness mechanism, approved preserved baseline evidence, or a separately provisioned baseline worktree. Escalate when the approved baseline cannot be obtained comparably.

### 4. Execute only the approved evaluation

Before execution, verify the approved patch digest, evaluation digest, bundle boundary, remaining limits, and required destinations. Snapshot relevant configuration, prompts, parameters, dataset identity, software versions, and environment metadata with secrets redacted.

Run only the approved commands and preserve raw outputs before transformation. Give retries and reruns distinct paths and record their reasons; never overwrite an earlier attempt. Ask First Mate to resolve routine permissions or transient failures only within the approved envelope.

Before substantive execution begins, a material patch change returns to patch review and then evaluation review, and an evaluation-proposal change returns to evaluation review. Once substantive execution begins, any material patch or evaluation change, additional evaluation, or rerun that would create new evidence requires `HUMAN_TRIAGE_REQUIRED` and a separately provisioned run. Do not repair unrelated failures unless they invalidate the target execution and the user approves the changed contract through the appropriate new run.

### 5. Analyze and report

Create an informative but concise `REPORT.md` from the observed evidence. Lead with the outcome, make the report easy to scan, and link to detailed provenance and raw evidence instead of duplicating them. Keep run status separate from hypothesis outcome, distinguish direct observations, interpretation, and untested ideas, and use relative links so the bundle remains portable.

Read [report format](references/report-format.md) before writing or materially correcting the report.

### 6. Finalize and hand off

Finalize valid `RUN_MANIFEST.json`, inventory and hash all regular bundle files except the manifest itself, reject symlinks, verify the inventory against the source files, recheck the worktree boundary and patch identity, and emit exactly one terminal status:

- `RUN_COMPLETE`
- `RUN_INCONCLUSIVE`
- `RUN_INVALID`
- `RUN_ABANDONED`

Send the structured completion handoff to First Mate and stop. `HUMAN_TRIAGE_REQUIRED` is a resumable interruption, not a terminal result. Do not import the bundle, update collection documentation, or continue into another run.

## Iteration and corrections

Before substantive execution, user-requested patch revisions that preserve the approved hypothesis and intervention, and evaluation-proposal revisions, may remain in the same run with new identities and renewed approval. A changed hypothesis or intended intervention, post-execution material patch or evaluation change, additional evaluation, or substantive rerun requires a new immutable run ID, worktree, agent, and bundle. A later run may cite an earlier run but must not mutate or reuse its writable directory.

A reporting-only correction may update a not-yet-archived `REPORT.md` when it does not change evidence or materially reinterpret the result. Regenerate and verify the manifest inventory, then send a corrected terminal handoff so First Mate verifies the current source bundle. Any material reinterpretation returns to user disposition rather than being silently edited.
