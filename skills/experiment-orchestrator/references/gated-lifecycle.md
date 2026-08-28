# Gated Lifecycle and Protocol

Read this reference when provisioning experiment runners, presenting gates, interpreting runner signals, or handling a material change.

## Protocol

Use `experiment-protocol/v1` for manager-runner messages and require `experiment-run-bundle/v1` for runner output. Include both applicable versions in launch and terminal messages and preserve them in archived provenance. A missing or mismatched version requires `HUMAN_TRIAGE_REQUIRED` before further execution or consolidation.

Every gate handoff should identify:

```text
Protocol: experiment-protocol/v1
Signal: <signal>
Collection: <collection-id>
Experiment: <experiment-id>
Run: <run-id>
Agent and pane: <identifiers>
Repository and origin: <repository and commit>
Branch and worktree: <branch and absolute worktree>
Run directory: <absolute in-worktree path>
Phase: <current lifecycle phase>
Decision required: <one specific decision>
Evidence: <paths and concise summary>
Risks or deviations: <material concerns>
```

The signal routes the handoff; the remaining fields establish identity, evidence, and the user's decision.

Use this phase model when classifying a runner's state:

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

`HUMAN_TRIAGE_REQUIRED` is a resumable interruption, not a terminal status.

## Approval receipts

Accept a semantic approval only when the user states it directly or First Mate explicitly relays that the user made the decision. Record:

```text
Decision owner: user
Relayed by: <First Mate identity or direct-user>
Gate: <plan | patch | evaluation>
Decision: <approved | changes-requested | rejected | abandoned>
Bound identity: <plan freeze reference, patch revision and digest, or evaluation revision and digest plus current patch identity>
Decision reference: <message, pane, or other available trace>
```

Do not accept silence, elapsed time, collection approval, a generic instruction to continue, an ordinary command approval, or First Mate's own decision as a semantic approval.

## Gate 1: Collection and variant approval

First Mate and the user agree on the statement of work and autonomy envelope, including:

- problem, objective, hypotheses, variants, controls, baseline, and origin commit;
- scope, non-goals, minimal expected patch shape, and anti-overfitting constraints;
- datasets, metrics, evaluation principles, comparison requirements, and decision criteria;
- model, reasoning, tools, services, credentials, data access, commands, and routine authority;
- runtime, cost, concurrency, retry, and stopping limits;
- collection archive, in-worktree bundle locations, required artifacts, and reports; and
- every human gate and the evidence required to decide it.

After approval, First Mate may initialize the manager-owned collection directory with `STATEMENT_OF_WORK.md` and optional navigation. Do not provision editing agents until the user approves the plan. Gate 1 authorizes collection initialization, provisioning, and briefing—not implementation, run import, or synthesis.

## Provisioning

Create one branch, worktree, Herdr location, agent, and immutable run ID for each editing run. All runs begin at the approved origin commit unless the approved variant explicitly states another baseline.

The initial prompt must explicitly invoke `$experiment-runner`, declare `experiment-protocol/v1` and `experiment-run-bundle/v1`, provide every required launch input, and start the worker in briefing-only mode. Include the hypothesis, current phase, routine decisions First Mate may resolve, approval-relay convention, baseline and comparison method, baseline-worktree owner when applicable, stopping limits, and required terminal fields. Verify that the absolute run directory resolves beneath the absolute worktree root before sending the prompt.

Parallel agents may read the same approved baseline but may not share a checkout, branch, run directory, writable artifact location, or collection document. Limit concurrency to the approved envelope.

## Gate 2: Agent understanding and final plan approval

Temporarily mark the agent pane as interactive. The user confirms that the agent received and understands the plan. The agent may inspect repository state, discuss assumptions, and amend `EXPERIMENT_PLAN.md` with changes the user explicitly accepts; it may not change product code or run evaluations.

The final plan should state the hypothesis, minimal intervention, scope, non-goals, baseline, inputs, variables, controls, evidence, evaluation principles, decision criteria, risks, artifacts, and autonomy envelope. The user approves execution explicitly. Record an approval receipt bound to the plan freeze reference; that approval freezes the plan for the run and returns the pane to managed supervision.

A material change after freeze normally requires a new run. If the user permits an in-run amendment, record it without erasing the original and repeat every affected gate.

## Gate 3: Patch approval

The runner constructs the smallest useful patch, performs only approved smoke checks, generates `implementation.patch` from Git against the recorded origin, and emits `PATCH_REVIEW_REQUIRED`.

The handoff must add:

- patch revision, patch path, SHA-256 digest, and origin commit;
- changed files and an explanation of each material change;
- why the intervention is minimal and causally relevant;
- unexpected or out-of-scope changes;
- smoke checks; and
- functional and evidential risks.

First Mate verifies the packet and presents it. Only the user may approve, revise, reject, or abandon the patch. Record the decision receipt. Revision increments the patch revision and returns to this gate. Approval binds only the reviewed revision and digest; any later behavior-changing difference invalidates patch and evaluation approval.

## Gate 4: Evaluation approval

After patch approval, the runner emits `EVALUATION_REVIEW_REQUIRED` with:

- approved patch revision and SHA-256 digest;
- evaluation revision, proposal path, and SHA-256 digest;
- baseline and treatment conditions;
- exact commands or entry points;
- cases, datasets, samples, repetitions, concurrency, and controls;
- metrics and decision criteria;
- targeted tests or smoke checks;
- exact in-worktree output and artifact paths;
- estimated runtime, model usage, external cost, and retry allowance; and
- validity risks and known limitations.

Only the user may approve this design and spend. Record a decision receipt bound to both the current patch identity and evaluation revision and digest. A proposal revision before substantive execution may remain in this run but returns here for approval. A material patch change returns first to Gate 3 and then requires a new Gate 4 proposal.

## Autonomous evaluation and reporting

After Gate 4 approval, First Mate resumes managed supervision. The runner executes only the approved commands and preserves raw evidence before transformation. First Mate may resolve routine permissions, questions, and transient failures only within the envelope.

Use `HUMAN_TRIAGE_REQUIRED` for changes to scope, hypothesis, patch, evaluation, cost, limits, validity, comparability, credentials, or other reserved decisions. Routine command prompts and expected transient failures are not semantic gates.

Once substantive execution begins, a material patch or evaluation change, additional evaluation, or rerun that creates new evidence requires a new run ID, worktree, agent, and bundle. Do not append a materially different execution to the current bundle.

## Gate 5: Run disposition

The runner ends with one status:

- `RUN_COMPLETE`: interpretable evidence and a completed bundle;
- `RUN_INCONCLUSIVE`: interpretable execution that did not resolve the hypothesis;
- `RUN_INVALID`: execution occurred but evidence cannot support a conclusion; or
- `RUN_ABANDONED`: the run stopped without a complete evaluation.

Keep terminal run status separate from hypothesis outcome (`supported`, `partially-supported`, `not-supported`, `unresolved`, or `not-assessed`). First Mate verifies `RUN_MANIFEST.json`, the bundle inventory, and consistency among the manifest, concise report, and terminal handoff, then summarizes the result. The user chooses reporting correction, a new amended run, another evaluation as a new run, abandonment, retention without archival import, or selection for archival consolidation.

Require the terminal handoff to include the bundle format; run status and hypothesis outcome; concise result; patch and evaluation revisions and digests; absolute in-worktree manifest, plan, patch, report, config, output, and artifact paths; commands actually run; retries and deviations; limitations and unresolved concerns; and a recommended disposition. Missing fields return to the runner for completion rather than being inferred.

No selection means no archive write. A reporting-only correction may update a not-yet-archived report when it does not alter evidence or materially reinterpret the result. Any substantive change creates a new run.

## Gate 6: Consolidation and synthesis approval

For each user-selected run, First Mate verifies and imports exactly that immutable `experiment-run-bundle/v1` bundle into the destination derived from its collection, experiment, and run IDs. Verify the source manifest, copy without changing bundle files, reject an existing destination, and verify the destination inventory against the source manifest. Progressive selection is allowed: later completed runs may be imported separately and enrich existing experiment and collection reports.

Approval to import one bundle authorizes only that import and its draft navigation or synthesis updates. It does not approve another bundle, finalize the synthesis, merge code, publish results, delete worktrees, or consolidate unrelated material.

Present the updated collection report and its evidence links to the user. The user approves, corrects, or leaves the synthesis in draft. Consequential repository actions remain separate First Mate gates.
