# Run Bundle Contract

Read this reference when creating the bundle, recording provenance or retries, checking isolation, or finalizing the manifest.

## Portable source bundle

Use the exact absolute run directory supplied at launch. A typical location is:

```text
<worktree>/experiment-runs/<collection-id>/<experiment-id>/run-<immutable-id>/
├── RUN_MANIFEST.json
├── EXPERIMENT_PLAN.md
├── implementation.patch
├── REPORT.md
├── artifacts/
├── configs/
└── outputs/
```

The exact repository-relative root is configurable. The collection, experiment, and run IDs must match the launch contract. The bundle is an archive-ready leaf: First Mate must be able to copy it unchanged into a manager-owned collection after user approval.

Use relative internal links. Do not depend on sibling files, shared writable directories, the main checkout, or absolute source paths for interpretation. Absolute execution paths belong only in provenance fields.

## Boundary checks

During briefing, before evaluation, and before completion:

1. Resolve the real worktree and real run-directory paths.
2. Confirm that the run directory is a strict descendant of the worktree.
3. Inspect bundle entries for symlinks or resolved targets outside the run directory.
4. Confirm all durable command outputs use approved bundle destinations.

Bundle content must not be stored in `/tmp`, home-directory caches, the manager archive, the main checkout, or another worktree. Tool-managed ephemeral caches are not evidence and must not be referenced as bundle content. Export required evidence into the bundle when permitted.

A boundary violation requires `HUMAN_TRIAGE_REQUIRED`. Do not disguise an external file as an artifact pointer or declare the bundle complete while required evidence remains outside it.

## Required contents

### `EXPERIMENT_PLAN.md`

Record the initial plan and user-approved briefing amendments. Before freeze, include the hypothesis, minimal intervention, scope, non-goals, origin, inputs, variables, controls, evaluation principles, decision criteria, risks, artifacts, autonomy envelope, and human gates.

At execution approval, record the available decision reference and freeze the file. Do not rewrite it after results are known. Later deviations belong in `REPORT.md` and `RUN_MANIFEST.json`.

### `implementation.patch`

Represent the exact implementation used to generate evidence against the recorded origin commit. Include behavior-relevant additions, modifications, deletions, and binary changes, but exclude the run bundle itself. Record an explicit no-code-change patch when applicable.

Hash the exact file with SHA-256. Recheck that the worktree implementation still corresponds to the approved patch before and after substantive evaluation. A behavior-changing difference invalidates the patch and evaluation approvals.

### `configs/`

Preserve the approved evaluation proposal, prompts, parameters, dataset identities or definitions, relevant software versions, and reproducibility metadata. Give proposal revisions stable, non-overwriting names such as `evaluation-proposal-r001.md`.

Redact credentials, tokens, secrets, and disallowed sensitive data. Record that a value was redacted and how an authorized reproducer should supply it rather than copying it.

### `outputs/`

Store primary raw execution outputs, model responses, evaluation results, direct logs, and targeted-test output before transformation. Use distinct attempt or retry paths, for example `attempt-001/` and `attempt-002/`. Never replace a failed or less favorable output with a later result.

### `artifacts/`

Store plots, trace exports, generated documents, screenshots, and intermediate analysis needed to interpret the evidence. Derived artifacts should identify their source outputs and transformation.

### `REPORT.md`

Provide a concise, outcome-first account of the run and link to bundle evidence with relative paths. Keep exhaustive provenance, commands, and raw detail in the manifest, configs, and outputs rather than duplicating them. Follow [report format](report-format.md).

## `RUN_MANIFEST.json`

Use bundle format `experiment-run-bundle/v1`. The manifest should contain at least:

```json
{
  "bundle_format": "experiment-run-bundle/v1",
  "protocol": "experiment-protocol/v1",
  "collection_id": "<collection-id>",
  "experiment_id": "<experiment-id>",
  "run_id": "<immutable-run-id>",
  "repository": "<repository>",
  "origin_commit": "<exact-commit>",
  "branch": "<branch-at-execution>",
  "worktree_at_execution": "<absolute-worktree>",
  "run_directory_at_execution": "<absolute-run-directory>",
  "model": "<model>",
  "reasoning_effort": "<effort>",
  "approval_receipts": [],
  "patch": {
    "revision": 1,
    "sha256": "<digest>",
    "path": "implementation.patch"
  },
  "evaluation": {
    "revision": 1,
    "sha256": "<digest-or-not-run>",
    "proposal_path": "configs/evaluation-proposal-r001.md"
  },
  "run_status": "<terminal-signal>",
  "hypothesis_outcome": "<outcome>",
  "commands_run": [],
  "retries": [],
  "deviations": [],
  "validity_concerns": [],
  "remote_evidence": [],
  "files": []
}
```

Each `files` entry should use a bundle-relative path, file role, byte size, and SHA-256 digest. Inventory every regular file except `RUN_MANIFEST.json` itself to avoid a circular checksum. Reject symlinks. Sort entries consistently when practical.

Record plan, patch, and evaluation approval receipts using the fields in [protocol v1](protocol-v1.md), without inventing identities or timestamps. Patch receipts bind the revision and digest; evaluation receipts bind the evaluation revision and digest together with the current patch revision and digest. For a run abandoned before a patch or evaluation exists, use an explicit `not-created` or `not-run` value and explain why.

## Immutability and consolidation

Never overwrite an earlier run or retry. Before substantive execution, approved patch revisions that preserve the hypothesis and intervention, and evaluation-proposal revisions, may remain in this bundle with distinct revision records. A changed hypothesis or intervention, post-execution material patch or evaluation change, additional evaluation, or substantive rerun receives a new run ID and separately provisioned worktree and bundle.

The runner never chooses an archive destination or writes the manager archive. After run disposition, First Mate may copy a user-selected completed bundle unchanged into the orchestrator's ID-derived destination, verify the copied manifest byte-for-byte and the destination inventory against the source, and update manager-owned navigation and synthesis outside the archived run leaf. Archive selection does not authorize source-bundle deletion or worktree cleanup.

A permitted reporting-only correction before archival import requires a regenerated and verified manifest inventory and a corrected terminal handoff. Do not mutate an archived bundle or materially reinterpret evidence as a reporting correction.
