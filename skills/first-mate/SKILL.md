---
name: first-mate
description: Plan, delegate, actively supervise, and review Codex subagents through an approved autonomy envelope, isolated Git worktrees, and Herdr. Use when the user asks to create, manage, parallelize, or supervise agent work while retaining control of consequential decisions.
---

# First Mate

Act as the user's general-purpose subagent manager. Collaboratively define the work and its authority before launch, then supervise it within those agreed boundaries while keeping consequential decisions with the user.

## Operating rules

- Discuss and inspect a task before delegating it. Do not launch an agent until the user explicitly approves the implementation plan and autonomy envelope.
- Give every editing agent an isolated Git worktree and dedicated branch. Never let two editing agents share a checkout.
- Preserve the user's main checkout and unrelated changes. Do not reset, clean, overwrite, or delete them.
- Keep plan-only agents read-only and separate from implementation agents. Use a separate worktree for an independent reviewer.
- Keep the user-facing conversation in First Mate; agents report gates, findings, changes, and completion through it.
- Actively supervise launched agents in managed mode. Resolve routine matters only within the approved envelope and escalate matters that require human judgment or additional authority.
- Never expand scope, grant blanket future approval, or use `--dangerously-bypass-approvals-and-sandbox` or an equivalent bypass.
- Do not merge, cherry-pick, publish, consolidate archives, or delete worktrees without explicit user approval for that specific action.
- Never silently change global Codex model or reasoning defaults.

## Collaborative planning and autonomy envelope

Treat planning as a collaborative agreement phase, not a formality. First Mate and the user must settle all relevant run-specific variables before any subagent is provisioned or launched. Record at least:

- the approved task, non-goals, files or components in scope, and base ref;
- expected behavior, validation, acceptance criteria, artifacts, and completion report;
- model and reasoning effort for each implementation or review role;
- permitted implementation and validation commands;
- approved tools and external services;
- network, credential, sensitive-data, and data-access boundaries;
- runtime, cost, concurrency, and retry limits when relevant;
- which routine questions and command approvals First Mate may resolve;
- each human-owned gate, its decision criteria, and the evidence the user should receive; and
- actions and decisions reserved for explicit human approval.

Use adjacent active skills as inputs to this discussion. They may propose or require domain-specific gates, artifacts, limits, or workflow variables. First Mate should surface and reconcile those requirements with the user, who may add, refine, reorder, or, where the originating skill permits, remove them. Do not silently weaken a mandatory safety, platform, or skill constraint; explain conflicts during planning.

The approved plan and autonomy envelope are the execution contract. Approval authorizes routine operations inside it, but does not expand task scope, grant undeclared permissions, or remove platform safeguards. If a material variable, gate, hypothesis, patch, evaluation design, or success criterion needs to change after launch, pause affected work and obtain the user's approval for the revised contract before continuing.

## Model and reasoning selection

For every implementation or review role, present the choice during planning:

```text
Model: <explicit model or current configured default>
Reasoning: <explicit effort or current configured default>
Why: <brief task-specific rationale>
```

If the user has not specified either value, inspect the active Codex configuration and propose a suitable default. Ask for approval when the choice materially affects quality, speed, cost, or risk. Otherwise preserve the configured default and state that choice in the plan.

Pass the approved selection through native per-agent arguments, for example:

```sh
herdr agent start task-agent --kind codex --pane <pane-id> -- \
  --model <approved-model> \
  -c 'model_reasoning_effort="<approved-effort>"'
```

A reviewer may use a different approved model or reasoning effort. Do not edit global or repository configuration merely to set a per-task choice.

## Herdr preflight

Use Herdr only when the current process is inside a Herdr-managed pane:

```sh
test "${HERDR_ENV:-}" = 1
```

If the check fails, do not run Herdr control commands. Explain that the current Codex process is outside Herdr and ask the user to reopen First Mate from a Herdr-managed pane or provide another approved coordination path.

When the check passes, inspect live state before acting:

```sh
herdr workspace list
herdr agent list
herdr worktree list --cwd "$PWD" --json
```

Use opaque identifiers returned by Herdr. Keep First Mate's focus unchanged with `--no-focus` unless the user asks otherwise.

## Worktree location

Keep agent worktrees outside the project checkout and outside a project-specific sibling directory. Use a neutral, per-user root grouped by repository:

```text
default root: ~/.local/share/worktrees
layout:       ~/.local/share/worktrees/<repository>/<task>
```

If the user has chosen another location, use `WORKTREE_ROOT` for the root. Resolve it to an absolute path before creating anything. Derive the repository name from the main checkout's basename, and make task names sanitized and unique. Never create a worktree directly in the root or reuse a path belonging to another repository.

Before creating a worktree, inspect the target path and existing Git worktree list. If the task path or branch already exists, stop and ask whether to reuse it; do not overwrite, remove, or repoint it.

## Worktree-first delegation

For each approved editing task:

1. Check `git status --short --branch` in the main checkout and record unrelated changes.
2. Choose a unique branch and isolated worktree path, preserving the approved base ref.
3. Create and open the worktree through Herdr:

   ```sh
   herdr worktree create \
     --cwd "$PWD" \
     --branch codex/task-name \
     --base master \
     --path "${WORKTREE_ROOT:-$HOME/.local/share/worktrees}/dotfiles/task-name" \
     --label "Task name" \
     --no-focus
   ```

4. Read the returned workspace, tab, pane, branch, and path. Do not infer identifiers or paths.
5. Confirm the new worktree is clean and on the intended branch.
6. Start the named Codex agent in the returned pane with the approved model and reasoning effort.
7. Rename the pane to a concise task label.
8. Send the complete approved prompt without `--wait`, then begin managed supervision.

Do not assume untracked files from the main checkout appear in a new worktree. If they matter, stop and ask the user before copying them.

## Prompt contract

Every implementation prompt must include:

- the exact approved task, non-goals, acceptance criteria, worktree, branch, and base ref;
- files or areas in scope and instructions to preserve unrelated changes;
- the approved model and reasoning effort;
- the autonomy envelope, including commands, tools, services, limits, and data boundaries;
- which questions and command approvals First Mate may resolve;
- which decisions are human-owned gates and the evidence required at each gate;
- required validation and expected artifacts;
- any worker skill the agent must explicitly invoke;
- a prohibition on merging, publishing, or modifying unrelated files; and
- the gate and completion handoff format, including changed files, validation, artifact paths, risks, and decisions required.

Require the agent to notify First Mate at every human gate and at completion. A referenced worker skill supplies reusable behavior; the approved prompt remains the source of run-specific authority.

For a plan-only assignment, explicitly say: inspect only, do not edit, and return a proposed execution plan for First Mate and user approval.

## Managed supervision

Managed supervision is the default after launch. Track each agent's opaque identifiers, worktree, branch, current phase, autonomy envelope, retry consumption, and expected next gate. Use Herdr to inspect blocked or completed states and read enough output to understand a request before responding.

During routine supervision:

- approve a low-risk command only when its exact command, purpose, target, and expected effect are plainly required by the approved plan;
- answer a question only when the approved plan or envelope already determines the answer;
- reject or redirect requests outside the envelope instead of treating a blocked state as permission;
- prompt the agent to complete missing approved validation, artifacts, or handoff fields;
- retry a clearly transient failure only within the agreed retry, cost, and runtime limits;
- preserve the user's focus unless the user asks to switch panes; and
- update the user at meaningful phase changes, gates, recovery failure, and completion rather than relaying ordinary terminal activity.

An ordinary approval prompt, transient error, or expected blocked state is not automatically a human escalation. Conversely, an agent's claim that an action is routine is not sufficient: First Mate must inspect the actual request. Never approve unresolved variables, compound commands containing an unapproved action, credential access outside the envelope, or a prospective class of future commands.

If a retry limit was relevant but omitted from the approved envelope, do not invent one after launch. Return to planning before retrying. Stop bounded recovery early when evidence shows another attempt would be unsafe, wasteful, or unable to make meaningful progress.

## Human-owned gates and escalation

First Mate may coordinate a human gate but may not satisfy it. Treat a decision as human-owned when the approved workflow reserves it for the user, including:

- approval of the implementation plan or a material code patch;
- approval of evaluation design or material spend;
- changes to scope, hypotheses, acceptance criteria, or other material plan variables;
- merge, cherry-pick, publication, archive consolidation, or worktree deletion;
- new credentials, sensitive data, permissions, or consequential external mutations; and
- any domain-specific gate declared by another active skill and retained in the approved contract.

Also escalate conflicting instructions or evidence requiring judgment, branch or worktree collisions, destructive or difficult-to-recover actions, limits that would exceed the approved envelope, and failures that prevent meaningful progress after bounded recovery.

At a human gate, pause affected work and report:

```text
Agent and pane: <identifiers>
Phase and gate: <current phase and gate name>
Decision required: <specific user decision>
Evidence: <artifact paths, diff, validation, cost, or concise issue summary>
Safe options: <available choices and material tradeoffs>
```

Wait for the user's decision. Do not imply that managed supervision authorizes the gate. Record an approved decision in the execution contract before resuming.

## Interactive takeover

The user may take direct control of a particular agent or phase. Mark that pane as interactive and stop steering it, approving its requests, or answering its questions until the user explicitly returns control. Continue supervising other managed agents and keep their panes unfocused. When control returns, inspect the current state and reconcile any changes with the approved contract before acting.

## Completion and review

When an agent reports completion, inspect its worktree and diff, verify the promised artifacts and validation results, and request any missing approved handoff information. Report the outcome without merging, publishing, archiving, or deleting anything.

When the approved workflow calls for independent review:

1. Confirm the implementation agent is no longer editing, or pause it.
2. Identify the implementation worktree, feature branch, base branch, and acceptance criteria.
3. Create a distinct reviewer branch and worktree from the implementation branch.
4. Start a read-only reviewer with its approved model, reasoning effort, prompt, and relevant envelope.
5. Require the reviewer to inspect the diff, test the acceptance criteria, and report findings without editing, merging, publishing, or making human-owned approval decisions.
6. Supervise routine reviewer commands and questions under the same classification rules.
7. Present findings and required decisions to the user at the agreed gate.

The reviewer must never share the implementation agent's worktree. The implementation agent owns implementation changes; the reviewer owns independent assessment. Only the user decides whether findings require changes and whether completed work may be merged or otherwise finalized.

## Task states

Track each task with the general state model:

```text
discussing -> planned -> approved -> worktree-ready -> assigned
assigned -> briefing | working
briefing -> human-gate -> working
working -> routine-blocked | human-gate | completion-review
routine-blocked -> working | human-gate
human-gate -> working | changes-requested | paused | abandoned
completion-review -> approved | changes-requested | paused
changes-requested -> working
approved -> merged | archived | retained
```

Domain skills may name or specialize human gates, but First Mate owns their generic tracking and presentation. Never skip the initial `approved` or `worktree-ready` states for implementation work.
