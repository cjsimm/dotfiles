# Run Report Format

Read this reference before writing or materially correcting `REPORT.md`.

## Readability contract

Make the report informative, concise, and easy to scan. Its job is to communicate the decision-relevant result and guide readers to deeper evidence, not to reproduce the entire run bundle.

- Lead with the outcome and strongest evidence.
- Prefer compact tables, short paragraphs, and bullets over dense narrative.
- Keep exact commands, complete configuration, approval receipts, retry histories, and exhaustive provenance in `RUN_MANIFEST.json`, `configs/`, and `outputs/`; link to them instead of repeating them.
- Include only material deviations, failures, limitations, and alternative explanations.
- Omit empty or irrelevant sections.
- Prioritize the most useful findings and follow-ups rather than creating exhaustive inventories.
- Do not narrate routine process or terminal activity.

Aim for roughly one to two readable pages for a normal run. This is a soft target: expand only when additional detail is necessary to understand the result or its validity.

## Evidence language

Keep these categories distinct:

- **Observed:** directly present in outputs, measurements, logs, or other run evidence.
- **Interpreted:** a reasoned explanation derived from cited observations.
- **Untested:** a plausible explanation or follow-up not established by this run.

Do not present an invalid run as negative evidence, an inconclusive result as a failed hypothesis, or successful command execution as support for the hypothesis.

## 1. Decision summary

Begin with a compact table or similarly scannable block containing:

- collection, experiment, and run IDs;
- repository and origin commit;
- hypothesis;
- minimal patch summary;
- run status: complete, inconclusive, invalid, or abandoned;
- hypothesis outcome: supported, partially supported, not supported, unresolved, or not assessed;
- strongest result or discriminating evidence; and
- most important limitation.

The reader should understand the outcome and its main caveat from this section alone.

## 2. Change tested

Briefly explain the causal intervention and why it was the minimum useful change. Link to `EXPERIMENT_PLAN.md` and `implementation.patch`; do not repeat the frozen plan, full changed-file inventory, or patch provenance already recorded elsewhere.

## 3. Evaluation and results

State the baseline, treatment, primary metric or decision criterion, and material execution conditions. Present key results in a compact table when that makes comparison easier. Link each material result to its owning raw output or artifact.

Do not repeat every command, parameter, case, or log entry. Mention a command, retry, failure, or configuration detail only when it materially affects interpretation; otherwise link to the manifest or configuration snapshot.

## 4. Interpretation and limitations

Explain whether and why the evidence supports the hypothesis. Separate direct observations from interpretation, then state only the limitations, deviations, alternative explanations, and generalization risks that could change the reader's decision.

For an inconclusive, invalid, or abandoned run, explain the decisive reason plainly rather than padding the report with unsuccessful process detail.

## 5. Recommended follow-ups

Include only high-value next questions or discriminating experiments. Usually provide no more than three, ordered by expected value. Label them as untested and make clear that they require a new approved run. Omit this section when there is no useful follow-up.

## Information placement

Use the report for synthesis and navigation. Use:

- `EXPERIMENT_PLAN.md` for the approved intent and constraints;
- `RUN_MANIFEST.json` for identities, provenance, approvals, commands, retries, deviations, and the file inventory;
- `configs/` for evaluation proposals, prompts, parameters, datasets, and environment snapshots;
- `outputs/` for raw execution evidence and logs; and
- `artifacts/` for derived analysis and supporting media.

## Linking and portability

Use paths relative to `REPORT.md`, such as `outputs/attempt-001/results.json`. Do not rely on absolute worktree paths for navigation. Ensure every material claim points to the owning evidence where practical.

Do not embed secrets, credentials, disallowed sensitive data, or unapproved proprietary inputs. Name redactions and access assumptions when they affect reproducibility.

## Completion consistency

Before handoff, confirm that `REPORT.md`, `RUN_MANIFEST.json`, and the terminal message agree on:

- protocol and bundle versions;
- IDs and origin commit;
- patch and evaluation identities;
- run status and hypothesis outcome;
- commands, retries, and deviations;
- evidence paths; and
- limitations and unresolved concerns.

Reporting corrections may not silently change raw evidence or materially reinterpret an already dispositioned run. Escalate a material reinterpretation to the user.
