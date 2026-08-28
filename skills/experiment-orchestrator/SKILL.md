---
name: experiment-orchestrator
description: Design and supervise isolated code experiments with explicit hypotheses, useful controls, human control of consequential decisions, and concise archived evidence. Use with First Mate for deliberate variants or iterative experimental runs; do not use for ordinary implementation or generic testing.
---

# Experiment Orchestrator

Use First Mate for coordination and this skill for experimental reasoning. Design experiments that produce comparable evidence without burdening workers with a transaction protocol.

## What must remain controlled

- State the question, hypothesis, causal intervention, baseline, treatment, evaluation method, and decision criteria before launch.
- Give each concurrently editing run its own agent, branch, and worktree. A baseline may use preserved evidence or a separate worktree when switching states would contaminate comparison.
- Keep unrelated refactors, fixture repair, metric changes, and case-specific overfitting out of the intervention unless they are the subject of the experiment.
- Keep credentials and disallowed sensitive data out of artifacts.
- Let the user control material changes, consequential spend or external effects, archival selection, code integration, publication, and cleanup.

Everything else should be optimized for finishing the experiment and learning from it.

## Approve one useful run brief

Collaborate with the user and First Mate on a compact collection plan and a self-contained brief for each run. The brief is the source of authority and must contain:

- objective, hypothesis, variant, baseline, and smallest useful intervention;
- scope, non-goals, origin commit, branch, and worktree;
- an explicit test plan: baseline and treatment conditions, cases or datasets, commands or entry points, metrics, repetitions when useful, comparison and success criteria;
- expected outputs and the evidence needed for a decision;
- model, reasoning, relevant domain skills the runner should invoke, tools, services, and data boundaries;
- authority for dependency installation, environment repair, network or sandbox escalation, low-cost retries, and reasonable test-plan adaptations;
- meaningful runtime, cost, concurrency, and stopping limits; and
- the decisions that must return to the user.

The user's approval of this brief authorizes the runner to inspect, prepare its environment, implement, run the stated evaluation, make non-material corrections, and report without pausing at artificial protocol checkpoints.

Use additional patch or evaluation gates only when the user asks for them or when the next action introduces a material change, material cost, new credentials or data, consequential external mutation, or a validity tradeoff the brief does not settle.

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

## Minimal evidence during the run

Do not require protocol versions, immutable message identities, approval receipts, per-file hashes, a manifest, or a complete inventory.

During execution, preserve enough evidence to avoid fooling yourself:

- the approved run brief or `EXPERIMENT_PLAN.md`;
- the actual code diff;
- decisive configuration and raw results;
- a concise `REPORT.md` describing commands, deviations, results, limitations, and conclusion.

Working files may live wherever the approved tools naturally create them, including temporary directories or remote evaluation services. Before cleanup or archival, copy the decision-relevant evidence into the selected archive and record stable remote links or identifiers when export is impractical. Never archive secrets.

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
└── runs/<run-id>/
    ├── EXPERIMENT_PLAN.md
    ├── implementation.patch
    ├── REPORT.md
    └── evidence/
```

Copy only decision-relevant evidence, preserve raw results that support material claims, refuse accidental overwrite, and link synthesis claims to their run. The archive—not a perfect working bundle—is the durable record. Archive approval does not authorize merge, publication, source deletion, or worktree cleanup.

In synthesis, distinguish observations, interpretations, and untested ideas. Compare only compatible conditions, retain negative or inconclusive results when informative, and surface contradictions rather than averaging them away.
