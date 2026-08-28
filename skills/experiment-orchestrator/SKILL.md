---
name: experiment-orchestrator
description: Design and supervise controlled code-experiment collections with explicit hypotheses, isolated runs, human-gated patches and evaluations, preserved evidence, and cross-run synthesis. Use with First Mate for deliberate variants or iterative experimental runs; do not use for ordinary implementation, generic tests, production monitoring, or informal exploration.
---

# Experiment Orchestrator

Supply experiment semantics while First Mate supplies generic coordination. Turn an experimental question into an approved collection of isolated runs whose patches, evaluations, evidence, reports, and conclusions remain traceable.

Use `experiment-protocol/v1` as the shared manager-runner message contract and accept only `experiment-run-bundle/v1` source bundles. If either version is missing or mismatched, pause with `HUMAN_TRIAGE_REQUIRED`; do not guess compatibility.

## Boundaries and ownership

- First Mate owns Herdr preflight, worktree and agent creation, model selection, routine supervision, approval classification, bounded recovery, human-gate presentation, user-decision relay, and verification or import of user-selected bundles. Follow `$first-mate`; this skill supplies the experiment-specific protocol data and must not duplicate or weaken its generic safeguards.
- This skill owns collection design, hypotheses and variants, experiment gates, provenance requirements, run disposition, archival selection, comparison, and synthesis.
- Each agent explicitly invokes `$experiment-runner`, produces and validates one `experiment-run-bundle/v1` source bundle, and owns one isolated run. It may edit only its worktree and must never edit the manager-owned collection archive or collection-level reports.
- The orchestrator defines bundle acceptance and archival placement. First Mate verifies and imports only a user-selected bundle; the user alone authorizes disposition and import.
- The user owns collection and variant approval, final run-plan approval, every material patch approval, evaluation design and spend approval, run disposition, archival selection, synthesis approval, and consequential repository actions.

One gate never authorizes a later gate. First Mate may supervise routine operations between gates but may never satisfy a semantic experiment gate.

## Non-negotiable isolation

Give every editing run its own branch, worktree, agent, immutable run ID, and run directory. A later iteration is a new run even when it tests the same hypothesis.

The complete working run bundle must remain inside its agent's worktree. Its manifest, plan, patch, report, configs, outputs, and artifacts must resolve beneath the approved worktree path; do not use symlinks, traversal, sibling worktrees, the main checkout, the collection archive, or external temporary directories to hold bundle content. First Mate verifies this boundary before launch and at completion.

Only First Mate may copy a user-selected completed bundle from its worktree into the manager-owned archive, and only after explicit consolidation approval. Read [collection structure and provenance](references/collection-structure.md) when choosing paths, verifying a bundle, iterating a run, or consolidating evidence.

## Collection planning

Before provisioning any editing agent, collaborate with the user under First Mate's autonomy-envelope workflow and approve:

- problem, motivation, objective, hypotheses, variants, controls, and baseline;
- repository, origin commit, scope, non-goals, and expected minimal intervention;
- datasets, evaluation principles, metrics, comparison conditions, and decision criteria;
- model and reasoning effort for each role;
- tools, services, credentials, data boundaries, commands, and routine authority;
- runtime, cost, concurrency, retries, and stopping conditions;
- collection archive location and manager-only write ownership;
- canonical archive hierarchy, in-worktree bundle root, run identities, `experiment-run-bundle/v1`, required artifacts, and provenance fields;
- all human gates, including requirements contributed by adjacent active skills; and
- expected collection reports, synthesis review, and consequential actions.

Gate 1 approval permits First Mate to initialize the manager-owned collection directory with `STATEMENT_OF_WORK.md` and optional navigation only; it does not permit run import or synthesis. Preserve the approved statement of work without rewriting it to fit later results. Record deviations in run or collection reports.

## Experiment design

Design each patch as the smallest intervention capable of testing one causal idea. Avoid unrelated cleanup, refactoring, production hardening, fixture repair, and changes to datasets, graders, metrics, or success criteria unless those are the experiment's subject. Treat experimental code as disposable unless the user later selects it for production work.

Do not overfit prompts or implementation logic to known evaluation cases. A score increase produced by special-casing observed examples is not evidence of a general improvement unless the approved hypothesis explicitly tests that behavior.

Prefer direct evidence from the relevant end-to-end or evaluation path. Do not run broad PyTest suites by default. Use targeted tests to establish that the patch is active or the relevant path executes. Record incidental failures without repairing them unless they prevent target behavior, corrupt the evaluation, invalidate evidence, or make baseline and treatment incomparable.

## Human-gated lifecycle

Use six user-owned gates:

1. Collection and variant approval.
2. Agent understanding and final run-plan approval.
3. Material patch approval.
4. Evaluation design and spend approval.
5. Run disposition.
6. Collection-synthesis approval after separately authorized run imports.

During Gate 2, place that pane into First Mate's interactive-takeover mode so the user can brief the agent directly. The agent may inspect and discuss but may not implement. Return the pane to managed supervision only after the user approves the final `EXPERIMENT_PLAN.md` and execution.

A material patch change invalidates patch approval. A material evaluation change invalidates evaluation approval. A changed hypothesis, intervention, evaluation design, or substantive execution normally creates a new run rather than mutating prior evidence.

An evaluation proposal may be revised before substantive execution within the same run, but every revision requires a new digest-bound Gate 4 decision. After substantive execution begins, any material patch or evaluation change, additional evaluation, or rerun with new evidence requires a new run. Reporting-only corrections may remain in an unarchived run only when evidence and material interpretation do not change.

Read [gated lifecycle and protocol](references/gated-lifecycle.md) before provisioning agents, presenting any gate, interpreting a worker signal, or changing an approved run.

## Provisioning and prompt contract

For each approved editing run, First Mate should create the isolated branch, worktree, Herdr location, and named agent from the approved origin commit without stealing focus. Start the agent in briefing-only mode and explicitly invoke `$experiment-runner`.

The launch prompt must include:

- protocol version, bundle format, collection ID, experiment ID, immutable run ID, and current phase;
- repository, origin commit, branch, worktree, and supervising First Mate identity or pane;
- initial plan path or complete plan, hypothesis, scope, non-goals, and expected implementation area;
- model and reasoning effort;
- autonomy envelope, permitted commands, tools, services, data and credential boundaries, routine decisions First Mate may resolve, and the approval-relay convention;
- runtime, cost, concurrency, retry, and stopping limits;
- baseline source and comparison method, including who provisions a separate baseline worktree when required;
- exact in-worktree run directory and the prohibition on writing bundle content elsewhere;
- gate ownership, required signals, approval receipt fields, and terminal handoff fields;
- required artifacts and expected disposition options; and
- an explicit instruction to start in briefing-only mode.

Before launch, First Mate should register these values in its supervision record, including the accepted protocol and bundle versions, immutable identities, current phase, allowed transitions, pending gate, exact run directory, and expected archive destination. Do not launch when an essential value is missing. Do not infer paths, baselines, identities, approvals, or archive authority.

## Signals and supervision

Recognize only these phase signals:

- `PATCH_REVIEW_REQUIRED`
- `EVALUATION_REVIEW_REQUIRED`
- `HUMAN_TRIAGE_REQUIRED`
- `RUN_COMPLETE`
- `RUN_INCONCLUSIVE`
- `RUN_INVALID`
- `RUN_ABANDONED`

The label identifies the phase; it does not authorize an action. Read the accompanying handoff, inspect the referenced evidence, verify protocol and identity, and apply the gate rules. Ask the runner to complete missing fields instead of guessing.

First Mate must also verify that the reported phase transition is permitted by `experiment-protocol/v1`. Treat `HUMAN_TRIAGE_REQUIRED` as a resumable interruption and retain the prior phase; do not classify it as a completed or abandoned run unless the user later chooses a terminal disposition.

Accept a semantic decision only from the user directly or from First Mate explicitly relaying the user's decision. Preserve a receipt containing decision owner, relaying identity, gate, decision, bound plan or revision-and-digest identity, and an available decision reference. Silence, a generic instruction to continue, collection approval, an ordinary command approval, or First Mate's own decision is not semantic approval.

After evaluation approval, let First Mate handle routine command approvals and bounded recovery inside the envelope. Escalate material changes to scope, patch, evaluation, cost, validity, or evidence comparability.

## Completion, disposition, and synthesis

At completion, require `RUN_MANIFEST.json` and verify the protocol and bundle versions, IDs, origin, branch, worktree, approval receipts, patch and evaluation identities, terminal status, hypothesis outcome, and file inventory. Confirm that every reported path exists inside the exact run directory, no bundle entry is a symlink, and every inventoried regular file has the recorded size and SHA-256 digest. Cross-check the manifest, report, and terminal handoff before disposition. Preserve negative, inconclusive, invalid, and abandoned outcomes when they provide meaningful information.

If the user requests an allowed reporting-only correction before import, require the runner to regenerate and verify the manifest inventory and issue a corrected terminal handoff. First Mate must replace the superseded completion record rather than combining fields or hashes from both handoffs.

The user decides whether to correct reporting, create a new run, approve another evaluation as a new run, abandon the investigation, or select the run for archival consolidation. Without selection, leave the bundle in its worktree and do not touch the collection archive.

Consolidate selected runs progressively as they finish. Each selection authorizes only the named bundle import and associated draft navigation or synthesis updates; it does not approve later imports or finalize the collection conclusions. Copy the source bundle unchanged into the canonical ID-derived destination, reject collisions, and verify the imported inventory against the source manifest before updating manager-owned documents. Compare only compatible evidence and trace material claims to run reports.

Read [consolidated reporting](references/consolidated-report.md) before creating or updating experiment-level or collection-level reports. Separate direct observations, cross-run inferences, and untested ideas, preserve disagreement, and present synthesis to the user for approval.
