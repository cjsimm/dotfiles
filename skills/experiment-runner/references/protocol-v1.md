# Experiment Protocol v1

Read this reference before validating a launch, emitting a gate or triage signal, or accepting an approval. This is the worker-side contract for `experiment-protocol/v1`.

## Message identity

Every launch, gate, triage, and completion message must include:

```text
Protocol: experiment-protocol/v1
Signal: <signal or LAUNCH>
Collection: <collection-id>
Experiment: <experiment-id>
Run: <immutable-run-id>
Agent and pane: <runner and supervising First Mate identifiers>
Repository and origin: <repository and exact commit>
Branch and worktree: <branch and absolute worktree>
Run directory: <absolute in-worktree path>
Phase: <current lifecycle phase>
```

Reject a message whose protocol, identities, origin, branch, worktree, or run directory conflicts with the accepted launch contract. Emit `HUMAN_TRIAGE_REQUIRED` for a protocol or identity conflict.

## Launch payload

In addition to message identity, `LAUNCH` must provide:

- `Bundle format: experiment-run-bundle/v1`;
- initial plan path or complete plan;
- hypothesis, scope, non-goals, and expected implementation area;
- model and reasoning effort;
- permitted commands, tools, services, data and credential boundaries;
- runtime, cost, concurrency, retry, and stopping limits;
- routine decisions First Mate may resolve;
- user-owned gates and the accepted approval-relay convention;
- baseline source and comparison method, including who provisions a separate baseline worktree when required;
- required artifacts and terminal handoff fields; and
- an explicit instruction to begin in briefing-only mode.

Do not infer a missing launch value. Request a corrected launch contract and remain in briefing mode.

## State transitions

```text
briefing -> plan-review
plan-review -> briefing | patching | terminal
patching -> patch-review
patch-review -> patching | evaluation-design | triage | terminal
evaluation-design -> evaluation-review
evaluation-review -> evaluation-design | evaluating | patching | triage | terminal
evaluating -> reporting | triage | terminal
reporting -> terminal | triage
triage -> prior-phase | terminal
```

Only explicit user execution approval moves `plan-review` to `patching`. Only approval bound to the current patch identity moves `patch-review` to `evaluation-design`. Only approval bound to the current evaluation identity and current approved patch moves `evaluation-review` to `evaluating`.

## Approval receipts

Accept a semantic approval only when it is either:

1. stated directly by the user during an interactive phase; or
2. relayed by First Mate with an explicit statement that the user made the decision.

The receipt must identify:

```text
Decision owner: user
Relayed by: <First Mate identity or direct-user>
Gate: <plan | patch | evaluation>
Decision: <approved | changes-requested | rejected | abandoned>
Bound identity: <plan freeze reference, patch revision and digest, or evaluation revision and digest plus current patch identity>
Decision reference: <message, pane, or other available trace>
```

Do not require a timestamp when the environment cannot establish one reliably. Do not accept silence, elapsed time, an ordinary shell approval, a generic instruction to continue, collection approval, or First Mate's own approval as a semantic gate decision.

## Gate signals

### `PATCH_REVIEW_REQUIRED`

Include the common identity fields plus:

- patch revision, patch path, SHA-256 digest, and origin commit;
- changed files and every material change;
- why the patch is minimal and causally relevant;
- unexpected or out-of-scope changes;
- smoke checks and their outputs;
- functional and evidential risks; and
- the exact user decision requested.

Pause until a receipt binds approval to that patch revision and digest. A pre-execution revised patch that preserves the approved hypothesis and intervention increments the revision and replaces the pending digest, while preserving prior review records in the report or manifest.

### `EVALUATION_REVIEW_REQUIRED`

Include the common identity fields plus:

- approved patch revision and digest;
- evaluation revision, proposal path, and SHA-256 digest;
- baseline source and treatment condition;
- exact commands, entry points, cases, datasets, samples, controls, repetitions, and concurrency;
- metrics, aggregation, and decision criteria;
- exact in-bundle configuration, output, and artifact paths;
- targeted checks;
- estimated runtime, model usage, external cost, and retry allowance;
- validity risks and limitations; and
- the exact user decision requested.

Pause until a receipt binds approval to that evaluation revision and digest and the current patch revision and digest. Before substantive execution, a revised proposal may remain in the same run with a new revision, digest, handoff, and user decision.

### `HUMAN_TRIAGE_REQUIRED`

Use this resumable interruption for a material question or conflict outside routine supervision. Include:

- the blocked phase and safe stopped state;
- the specific decision required;
- evidence and paths;
- effect on scope, patch, evaluation, cost, limits, validity, comparability, credentials, or bundle boundary;
- safe options and material tradeoffs; and
- approvals invalidated by each option.

Do not use triage for an ordinary command prompt or a transient failure First Mate can resolve inside the approved envelope.

Once substantive execution begins, a material patch or evaluation change, additional evaluation, or rerun that would create new evidence cannot return to patching or evaluation review in this run. Request a new run through triage and stop the current run safely.

## Terminal handoff

Use exactly one terminal signal:

- `RUN_COMPLETE`: execution produced interpretable evidence and a completed bundle;
- `RUN_INCONCLUSIVE`: interpretable execution did not resolve the hypothesis;
- `RUN_INVALID`: execution occurred but its evidence cannot support a conclusion;
- `RUN_ABANDONED`: the run stopped without a complete evaluation.

The terminal handoff must include:

```text
Bundle format: experiment-run-bundle/v1
Run status: <terminal signal>
Hypothesis outcome: <supported | partially-supported | not-supported | unresolved | not-assessed>
Result summary: <concise result>
Patch identity: <revision and SHA-256>
Evaluation identity: <revision and SHA-256, or not-run>
Manifest: <absolute in-worktree RUN_MANIFEST.json path>
Plan: <absolute in-worktree EXPERIMENT_PLAN.md path>
Patch: <absolute in-worktree implementation.patch path>
Report: <absolute in-worktree REPORT.md path>
Configs, outputs, artifacts: <absolute in-worktree paths>
Commands actually run: <ordered list>
Retries and deviations: <summary>
Limitations and unresolved concerns: <summary>
Recommended disposition: <correct-reporting | new-run | abandon-line | retain | consider-archive>
```

The absolute paths help First Mate verify the source worktree. Files inside the bundle should link to one another with relative paths so an approved copy remains portable.

If the user requests a permitted reporting-only correction before archival import, regenerate and verify the manifest inventory and send a corrected terminal handoff. Do not leave First Mate relying on paths or hashes from the superseded handoff.
