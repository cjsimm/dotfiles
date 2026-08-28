# Consolidated Reporting

Read this reference when updating an experiment-level roll-up, collection report, or follow-up proposal.

## Readability contract

Make manager-owned reports outcome-first, informative, concise, and easy to scan. Use compact comparison tables, short paragraphs, and bullets. Link to archived run reports and evidence instead of duplicating commands, configurations, provenance, or raw outputs. Include only decision-relevant differences, limitations, and follow-ups; omit empty sections and routine process narrative.

An experiment roll-up should normally fit on one or two readable pages. Keep the collection report as short as the number and diversity of accepted runs permit, with its abstract and index sufficient for a quick decision-oriented reading.

## Evidence language

Label claims by epistemic status:

- **Observed:** directly present in one or more run outputs or measurements.
- **Inferred:** a reasoned conclusion drawn from cited observations.
- **Speculative or untested:** a plausible explanation or proposal not established by the runs.

Do not turn correlation into causation, an invalid run into negative evidence, an inconclusive result into failure, or repeated measurements under the same condition into independent confirmation. Preserve contradictory results and identify incompatible conditions instead of averaging them into false consensus.

## Experiment-level report

Maintain one manager-owned `REPORT.md` for each hypothesis or experiment represented in the archive. Lead with the current result and most important caveat, then include:

- hypothesis and its relationship to the collection objective;
- index of every selected run with status and links;
- patch and evaluation differences across iterations;
- comparable results and relevant metrics;
- contradictions, invalid runs, regressions, and limitations;
- current support status and confidence; and
- remaining questions or recommended discriminating run.

Keep detailed evidence in the run that owns it. Do not duplicate raw outputs into the roll-up.

## Collection-level report

Create or update the collection `REPORT.md` with these sections when they add material information:

1. **Abstract:** problem, scope, hypotheses investigated, overall result, main recommendation, and most material limitation.
2. **Experiment index:** experiment, hypothesis, patch summary, evaluation, result, status, and links.
3. **Brief experiment summaries:** question, intervention, evidence, result, support status, limitation, and drill-down links.
4. **Cross-experiment synthesis:** converging evidence, single-run evidence, contradictions, non-comparable conditions, regressions, tradeoffs, and generalization limits.
5. **Findings and insights:** separate observations, cross-run inferences, and untested ideas.
6. **Recommended follow-ups:** unanswered question, motivation, hypothesis, minimal intervention, proposed evaluation, discriminating outcomes, priority, and dependencies.
7. **Conclusions:** established results, uncertainty, strongest current approach, production-readiness assessment, cautions, and recommended next action.

Include unsuccessful, inconclusive, invalid, and abandoned runs when they contribute useful information. State why excluded runs or metrics are not comparable. Keep exact commands, complete provenance, and raw evidence in the immutable run bundles rather than repeating them here.

## Traceability

Every material synthesis claim should link to one or more archived run reports and, where useful, the owning raw evidence. For each comparison, confirm that baseline, patch identity, dataset, metric definition, execution conditions, and aggregation are compatible. If they are not, describe the difference and avoid a direct ranking.

The collection report may evolve as the user selects additional completed runs. Preserve prior run bundles unchanged, identify newly incorporated evidence, and revise conclusions only to the degree supported by that evidence.

## Follow-up proposal

Include only high-value recommended experiments, usually no more than three. For each, state:

```text
Question: <unresolved issue>
Motivation: <why it matters>
Hypothesis: <falsifiable expectation>
Minimal intervention: <smallest useful change>
Evaluation: <direct test and controls>
Discriminating outcomes: <what would separate explanations>
Priority: <relative value and urgency>
Dependencies: <required evidence, tools, or prior runs>
Epistemic status: untested proposal
```

Recommendations do not authorize a new run. They return to Gate 1 planning and user approval.

## Synthesis gate

First Mate may draft and progressively enrich manager-owned reports after each approved bundle import. Present the updated report, its evidence links, unresolved conflicts, and proposed conclusions to the user. Only the user may approve the synthesis as final. That approval still does not authorize merge, publication, archive deletion, or worktree cleanup.
