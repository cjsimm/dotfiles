# Collection Structure and Provenance

Read this reference when selecting run paths, verifying bundle isolation, creating an iteration, or importing a selected run into the collection archive.

## Two storage boundaries

Maintain two distinct boundaries:

1. **Agent-owned working bundle:** lives entirely inside that run's isolated worktree while the runner works.
2. **Manager-owned collection archive:** receives only user-selected completed bundles through an approved First Mate consolidation step.

Experiment agents never write to the archive. They also never write bundle content to the main checkout, sibling worktrees, shared collection paths, or external temporary directories.

## In-worktree run bundle

Agree an absolute worktree and a repository-relative bundle root during planning. A typical layout is:

```text
<run-worktree>/experiment-runs/<collection-id>/<experiment-id>/run-<immutable-id>/
├── RUN_MANIFEST.json
├── EXPERIMENT_PLAN.md
├── implementation.patch
├── REPORT.md
├── artifacts/
├── configs/
└── outputs/
```

The exact root is configurable, but every component must resolve beneath `<run-worktree>`. Do not use symlinks or traversal that escape the worktree. Commands must direct bundle outputs to the approved subdirectories instead of `/tmp`, a home-directory cache, the master archive, or another run.

Before launch and at completion, First Mate should resolve the real worktree and bundle paths and confirm that the bundle path is a descendant of the worktree path. Inspect bundle entries for escaping symlinks. A boundary violation is `HUMAN_TRIAGE_REQUIRED`; do not consolidate until corrected or explicitly dispositioned.

Remote approved services may retain their own source records, but the run bundle must contain the exported evidence needed for interpretation and reproduction when export is available. When it is not, record stable remote identifiers, access assumptions, and the limitation in the run report.

## Bundle provenance

Each run bundle uses format `experiment-run-bundle/v1`. `RUN_MANIFEST.json` records:

- protocol version;
- collection, experiment, and immutable run IDs;
- repository and origin commit;
- branch and absolute worktree at execution time;
- approved plan and approval-relevant amendments;
- exact implementation patch and reviewed patch identity;
- approved evaluation configuration and commands actually run;
- relevant environment, model, prompt, dataset, and parameter snapshots;
- raw outputs before transformation;
- retries, deviations, failures, and validity concerns; and
- final status and report.

Require a bundle-relative inventory of every regular file except the manifest itself. Each entry records the path, role, byte size, and SHA-256 digest. Reject symlinks. Keep terminal run status distinct from hypothesis outcome, and verify that the manifest, report, and terminal handoff agree.

`EXPERIMENT_PLAN.md` freezes at execution approval and remains historical. `implementation.patch` must represent the code used to produce the evidence and identify its origin. If the run requires no code change, state that explicitly rather than omitting the patch provenance.

Use explicit filenames or subdirectories for retries and versions. Never silently overwrite earlier raw outputs, configurations, patches, plans, or results.

## Iteration

Before substantive execution, a patch revision that preserves the approved hypothesis and intervention, or an evaluation-proposal revision, may remain in the same run when it receives a new revision, digest, handoff, and user approval. A changed hypothesis or intervention, post-execution material patch or evaluation change, additional evaluation, or substantive rerun creates a new immutable run ID and a new in-worktree bundle. Give every editing run its own branch, worktree, and agent. A later run may cite an earlier run but must not reuse its writable directory or mutate its evidence.

## Manager-owned collection archive

Use a self-contained archive selected during Gate 1:

```text
<archive-root>/<collection-id>/
├── STATEMENT_OF_WORK.md
├── REPORT.md
├── README.md                         # Optional navigation only
├── experiments/
│   └── <experiment-id>/
│       ├── REPORT.md                 # Roll-up across selected runs
│       └── runs/
│           └── <run-id>/             # Unchanged runner bundle
│               ├── RUN_MANIFEST.json
│               ├── EXPERIMENT_PLAN.md
│               ├── implementation.patch
│               ├── REPORT.md
│               ├── artifacts/
│               ├── configs/
│               └── outputs/
└── shared/                            # Only genuinely shared inputs
```

`STATEMENT_OF_WORK.md` preserves the approved intent: problem, motivation, hypotheses, scope, non-goals, design, implementation expectations, datasets, metrics, decision criteria, outputs, assumptions, risks, constraints, and autonomy envelope. Do not rewrite it to match the outcome.

Derive each destination from the manifest's exact collection, experiment, and immutable run IDs. Do not rename, flatten, decorate, or inject manager-owned files into the archived run leaf. Use `README.md` only when navigation, ordering, or terminology is not obvious. Keep run-owned evidence inside its run directory. Use `shared/` only for genuinely common inputs, never as a convenience for agent writes.

## Approved consolidation

For each selected run, First Mate should:

1. Verify `experiment-protocol/v1`, `experiment-run-bundle/v1`, IDs, origin, branch, worktree, approval receipts, patch and evaluation identities, terminal status, hypothesis outcome, plan, report, configs, outputs, artifacts, and path boundary.
2. Resolve a collision-free destination for the exact collection, experiment, and run IDs.
3. Refuse to overwrite an existing archived run. A conflict requires human triage.
4. Reject symlinks and verify every inventoried source file's path, role, byte size, and SHA-256 digest.
5. Copy the complete bundle without editing, omitting, or adding files during transfer.
6. Confirm the copied manifest is byte-for-byte identical, then recompute the destination inventory and verify it against the source manifest and source files.
7. Add or update manager-owned navigation and draft synthesis outside the archived run leaf.
8. Trace every material summary claim to one or more archived run reports.

Archival selection does not authorize code merge, publication, source-bundle deletion, worktree deletion, or final synthesis approval.
