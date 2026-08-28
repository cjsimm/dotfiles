---
name: experiment-orchestrator
description: Design and supervise isolated code experiments with explicit hypotheses, useful controls, human control of consequential decisions, and concise archived evidence. Use with First Mate for deliberate variants or iterative experimental runs; do not use for ordinary implementation or generic testing.
---

# Experiment Orchestrator

Use First Mate for coordination and this skill for experimental reasoning. Design experiments that produce comparable evidence without burdening workers with a transaction protocol.

## What must remain controlled

- State the question, hypothesis, causal intervention, baseline, treatment, evaluation method, and decision criteria before launch.
- Give each concurrently editing treatment run its own agent, branch, and worktree. First Mate may take the baseline itself in a separate clean worktree without launching another agent.
- Keep unrelated refactors, fixture repair, metric changes, and case-specific overfitting out of the intervention unless they are the subject of the experiment.
- Keep credentials and disallowed sensitive data out of artifacts.
- Let the user control material changes, consequential spend or external effects, archival selection, code integration, publication, and cleanup.

Everything else should be optimized for finishing the experiment and learning from it.

## Approve one useful run brief

Collaborate with the user and First Mate on a compact collection plan and a self-contained brief for each run. The brief is the source of authority and must contain:

- objective, hypothesis, variant, baseline, and smallest useful intervention;
- scope, non-goals, origin commit, branch, and worktree;
- an explicit test plan: baseline and treatment conditions, cases or datasets, commands or entry points, metrics, repetitions when useful, comparison and success criteria;
- expected outputs, the in-worktree run directory, and the evidence needed for a decision;
- model, reasoning, tools, services, data boundaries, and an assistance plan containing only `Required assistance` and `Recommended assistance`;
- authority for dependency installation, environment repair, network or sandbox escalation, low-cost retries, and reasonable test-plan adaptations;
- meaningful runtime, cost, concurrency, and stopping limits; and
- the decisions that must return to the user.

The user's approval of this brief authorizes the runner to inspect, prepare its environment, implement, run the stated evaluation, make non-material corrections, and report without pausing at artificial protocol checkpoints.

For each assistance entry, name the exact skill or plugin-provided capability, state why it helps, and include any trigger or setup dependency:

- **Required assistance:** capabilities necessary to execute or interpret the run correctly. First Mate verifies availability before the dependent step and helps configure them. If one remains unavailable, the runner reports the concrete impact rather than silently substituting something materially different.
- **Recommended assistance:** capabilities expected to improve implementation, evaluation, or analysis. The runner uses them when relevant and may skip them with a brief reason when their trigger does not occur or their value no longer justifies the cost.

Name a plugin's callable skill, MCP tool, or app capability rather than only the plugin bundle. First Mate injects this assistance plan verbatim into the initial runner prompt. New plugin installation, credentials, permissions, or material cost remain subject to their normal user approval.

Use additional patch or evaluation gates only when the user asks for them or when the next action introduces a material change, material cost, new credentials or data, consequential external mutation, or a validity tradeoff the brief does not settle.

## Baseline preflight

After brief approval and before launching treatment agents, First Mate should capture a fresh baseline when practical. It owns environment setup, the approved baseline commands, routine recovery, and a lightweight baseline directory containing `BASELINE_RECORD.yaml`, `REPORT.md`, and decisive evidence. The record should preserve origin, inputs, configuration, environment discoveries, attempts, outputs, results, workarounds, cost or runtime, and comparability constraints.

First Mate summarizes the working setup, commands, baseline result and evidence, known problems, assistance used, and conditions treatment must preserve in every runner's initial prompt. An incomplete baseline is not a workflow failure: retain partial evidence, explain limitations, and launch the treatment when a useful comparison remains possible. Use a baseline subagent only when the user approves it because the work is independently complex or benefits from concurrency.

## Let runs adapt and persist

The runner may stay in the same run while it:

- fixes environment and dependency setup;
- resolves sandbox or network problems through native approval paths;
- corrects implementation mistakes that do not change the causal intervention;
- refines commands, output locations, concurrency, or retry mechanics without changing what is being measured;
- repeats failed or flaky attempts within the approved cost and validity limits; and
- adds targeted checks needed to establish that the intervention actually ran.

Record material deviations in the report. Create a distinct run when the hypothesis or causal intervention changes, or when mixing new evidence into the old run would make the comparison misleading. Do not terminate or “abandon” a run merely because an initial command, setup attempt, or evaluation failed.

First Mate should actively help with environment recovery and covered approvals. The runner should solve ordinary setup problems itself and request a native command approval when needed. Either the user or First Mate may satisfy such a prompt; no separate approval receipt is required.

## Lightweight artifacts and lineage

Do not require protocol versions, immutable message identities, approval receipts, per-file hashes, a manifest, or a complete inventory.

From the start of execution, keep durable run-owned artifacts in a small directory inside the runner's worktree. Preserve enough evidence to reproduce the comparison and trace every material conclusion:

- the approved run brief or `EXPERIMENT_PLAN.md`;
- the actual code diff;
- decisive configuration and raw results in unique, non-overwriting attempt paths;
- a `RUN_RECORD.yaml` connecting code origin, inputs, execution attempts, outputs, and derived artifacts; and
- a concise `REPORT.md` describing commands, deviations, results, limitations, and conclusion.

`RUN_RECORD.yaml` is a lineage map, not a manifest. Record the origin commit and tested patch or commit; baseline source; dataset, case, prompt, model, configuration, and relevant environment identities; each command attempt and why it was retried; the raw outputs produced by each attempt; transformations and their source outputs; derived artifacts; remote trace or evaluation identifiers; and material deviations. Use repository-relative or run-relative paths where possible. Do not add per-file hashes or inventory unrelated files.

Tools may use temporary directories, caches, or remote services while running, but decision-relevant evidence must be copied into the run directory before handoff. When approved remote evidence cannot be exported, record a stable identifier, access assumptions, and retention risk. Never record or archive secrets.

Every material claim in `REPORT.md` must link to the owning raw or derived evidence. Do not overwrite earlier attempts, even when they failed or produced an unfavorable result.

## Results presentation contract

Make each run's result understandable without opening its raw artifacts. Lead with the hypothesis outcome, recommended decision, strongest baseline-to-treatment comparison, and most important caveat. Normally include a compact comparison like:

```text
| Metric or case | Baseline | Treatment | Delta | Criterion | Result | Evidence |
```

Show absolute and relative deltas when meaningful, repetitions or uncertainty when available, regressions and failed cases alongside improvements, and whether each decision criterion was met. Identify the exact baseline source and say whether baseline and treatment conditions were comparable. Link each material row to its evidence.

This is a presentation contract, not a validity gate or rigid schema. Adapt it for qualitative, case-based, partially observed, or non-tabular evidence. If a value, delta, uncertainty estimate, or comparable baseline is unavailable, show the best supported comparison, mark what is unavailable, and explain why. Do not block, invalidate, or abandon a run merely because the preferred table or one of its fields cannot be produced.

For collection synthesis, present a compact comparison across selected variants when useful:

```text
| Run or variant | Baseline | Intervention | Primary result | Regressions | Validity | Conclusion |
```

Keep non-comparable conditions visibly separate and explain why; do not force them into a ranking or combined aggregate. Omit or adapt columns that do not help the reader.

## Completion and archive

Use plain states: `running`, `blocked`, `complete`, `inconclusive`, or `invalid`. A blocked run is resumable. Stop only when the user ends it, the stopping limit is reached, recovery needs unavailable authority, or further execution cannot produce interpretable evidence.

At handoff, provide:

- outcome and whether the hypothesis was supported, not supported, or unresolved;
- branch, worktree, origin, and changed files;
- evaluation actually run, key results, retries, and material deviations;
- paths or remote identifiers for the plan, diff, report, and decisive evidence;
- limitations, remaining risks, and recommended next action.

The user decides whether to retain, continue, rerun, integrate, or archive the result.

For a selected run, First Mate creates or updates a readable collection archive. Prefer this small structure unless the user needs more:

```text
<archive>/<collection>/
├── STATEMENT_OF_WORK.md
├── REPORT.md
├── baselines/<baseline-id>/
│   ├── BASELINE_RECORD.yaml
│   ├── REPORT.md
│   └── evidence/
└── runs/<run-id>/
    ├── EXPERIMENT_PLAN.md
    ├── implementation.patch
    ├── RUN_RECORD.yaml
    ├── REPORT.md
    └── evidence/
```

Copy the selected run's plan, patch, lineage record, report, decision-relevant evidence, and the baseline artifacts it relies on. Confirm that lineage paths and report links still resolve after copying, refuse accidental overwrite, and link synthesis claims to their run. Archive approval does not authorize merge, publication, source deletion, or worktree cleanup.

In synthesis, distinguish observations, interpretations, and untested ideas. Compare only compatible conditions, retain negative or inconclusive results when informative, and surface contradictions rather than averaging them away. Optimize the collection report for quick baseline-versus-variant decisions, with links to the supporting run evidence.
