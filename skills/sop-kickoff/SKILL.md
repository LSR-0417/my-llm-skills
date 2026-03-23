---
name: sop-kickoff
description: Kick off a development topic. Use when a new implementation discussion begins and Codex must review the active role's problem framing, confirm PM-provided `User Story` and TE-provided `Spec. Test` as the current development baseline, call out scope or clarity problems, and decide whether the topic is ready for `sop-workspace`.
---

# sop-kickoff

For the human-facing SOP, naming notes, and examples, read `README.md`.

This skill executes the kickoff gate. The active role skill defines the lens, responsibility boundary, and decision standard used during kickoff.

## Goal

- Validate whether the current topic is ready to enter workspace setup.
- Clarify scope, acceptance, risks, and development preconditions from the active role lens.
- Confirm the current `User Story` and `Spec. Test` baseline before coding starts.
- Draft the finalized kickoff result as a PM-style User Story Issue, tagged with `type: user-story`, and push it to the Git server.

## Workflow

1. Determine the active role (`role-pm`, `role-developer`, or `role-te`) and execute responsibilities accordingly.
2. **If PM (`role-pm`)**:
   - Clarify vague customer/stakeholder requirements and convert them into clear, reasonable, and feasible User Stories. 
   - Push the kickoff result as a User Story Issue to the Git server (Title: `<summary>`, Body: User Story, Acceptance Criteria, Notes), labeled with `type: user-story`.
   - If pushing to the Git server fails or is unsupported, remind the user and print the full Issue Title and Body in the chat for manual copy-pasting.
3. **If TE (`role-te`)**: 
   - Write `Spec. Test`, `Scenario Test`, and `Edge Test` strictly based on the PM's User Story.
   - If the User Story changes during development, MUST synchronously revise the corresponding tests to provide a reliable baseline for RD.
4. **If RD (`role-developer`)**: 
   - Implement features targeting the User Story and passing all tests created by the TE.
   - Only when the `User Story`, scope, and development preconditions are clear enough should workspace setup be handed to `$sop-workspace`.
5. Ensure there is a traceable issue or equivalent tracking record before implementation proceeds.

## Guardrails

- Do not write to, modify, or commit any files on protected main branches (e.g., `main`, `master`, `develop`) during the kickoff and discussion phase.
- Do not start coding directly from a vague topic.
- Do not assume the first version of `User Story` or `Spec. Test` is final.
- Do not ignore scope size, clarity gaps, or missing acceptance detail just to start faster.
- Do not proceed without a traceable issue or equivalent tracking context.
- Do not enter workspace setup unless the current baseline is clear enough for implementation.

## Stop Conditions

- The topic is still too vague to frame as an implementation-ready work item.
- The `User Story` is too large, unclear, or inconsistent to use as a safe development baseline.
- The required `Spec. Test` baseline is missing, stale, or clearly not aligned with the current topic.
- Traceability is missing because there is no usable issue or equivalent tracking record.
