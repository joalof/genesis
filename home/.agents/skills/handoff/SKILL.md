---
name: handoff
description: Write HANDOFF.md in the current directory so a fresh session can pick up where this one leaves off. It is organised by the core issues being worked on, not by what happened when. For each issue it records what was decided or done, what is still open, and the hard-won knowledge that shouldn't be paid for twice. Only use this when the user explicitly asks for a handoff.
disable-model-invocation: true
---

# Handoff

The user is ending a long session that leaves work unfinished. Write a document
that lets a future agent, with no memory of this session, continue the work.

The reader has the repo and this file. They don't have the conversation, your
tool output, or the reports from subagents. Anything you don't write down is
lost, and they will have to work it out again.

## What it is not

- **Not a summary or a log.** Don't write "first we..., then we...". Order is
  only kept where it matters for what happens next.
- **Not a record of everything.** A small fix that is finished and doesn't
  affect the open work stays out. Git history already has it.
- **Not a copy of the code.** Point to files and symbols instead of pasting
  them. Only quote a short snippet when its exact wording matters.

## Steps

1. **Find the threads.** Go through the session and name the 1–5 core
   questions, problems or features it was really about. Group by goal, not by
   when they came up: a bug found while building a feature is part of that
   feature's thread unless it grew into a separate effort. If earlier parts of
   the session were compacted, work from the summary and the files. Don't make
   up details you no longer have.
2. **Check the current state** instead of relying on memory. Run `git status`,
   `git diff --stat` and `git log` for this session's commits. Check that
   files you mention exist. Re-run a check if it is quick. Mark anything you
   couldn't verify as unverified.
3. **Look for an existing `HANDOFF.md`.** If there is one, it is probably what
   this session started from. Read it and write a new version: carry over
   points that are still open, remove the ones that are done, and keep
   knowledge that is still true. If it is about unrelated work, ask the user
   before overwriting it.
4. **Write `HANDOFF.md` in the current directory**, using the template below.
5. **Report back in a few lines:** the path, the threads (one line each), and
   a prompt the user can start the next session with, for example "Read
   HANDOFF.md and continue with thread 2." Don't commit the file unless asked.

If the user added instructions when invoking the skill, such as a topic to
focus on or a different file name, follow them.

## Template

```markdown
# Handoff: <short title of the overall effort>

<date> · `<cwd>` · branch `<branch>` @ `<short sha>`<, uncommitted changes in N files>

<1–3 sentences: the overall goal, so the threads below make sense.>

## 1. <Thread title, phrased as the question or feature>

**Background.** What this is about and why it matters, in a few sentences.
Point to where things live: `path/to/file.py:func`, docs, tickets, PRs.

**Decided / done.**
- <Decision>, because <reason>. <Rejected alternative, and why.>
- <What was implemented and where>, <tested? how?>

**Open.**
- <Remaining work, specific enough to start on>
- <Open question>. <Who can answer it: the user, an experiment, docs?>
- Next step: <the one thing to do first>

## 2. ...

## Hard-won knowledge

- <Fact or result>. <How it was established: command, script, agent search,
  experiment.> <Where the output lives.> <Which thread it serves.>
- Dead end: <approach> doesn't work because <reason>. Don't retry unless
  <condition changes>.

## Pointers

- <Key files, scripts, outputs, URLs a new session will want open.>
```

Leave out sections that would be empty. A thread that is fully done stays in
only if the open threads depend on it, and then it gets a short paragraph.

## What makes a good handoff

**Be specific.** Use paths relative to the current directory, function names,
exact commands, IDs, numbers with units, and full error messages. "Fixed the
loader" is useless. "`data/loader.py:read_shards` now skips empty shards;
before, it raised `IndexError` on `s3://bucket/run-7/`" is useful.

**Give the reason for each decision, and say who made it.** A decision without
its reason gets reopened. Record the alternatives that were rejected and why.
Keep these apart:
- the user decided or confirmed it
- you proposed it and the user didn't object
- you assumed it

The next agent should only rely on the first kind without checking.

**Keep the expensive knowledge.** This is the most valuable part of the
document. Write it down whenever finding something out cost real effort, for
example:
- calculations, benchmarks, profiling, or a long debugging session
- subagent research or codebase sweeps
- reading external docs
- trial and error

For each item:
- State the result itself, not "we looked into X".
- Say how it was obtained, so it can be re-checked or redone if the inputs
  change.
- Include the limits: "holds for the v2 schema only", "measured on 1k rows,
  not the full set".
- If the evidence lives somewhere temporary (`/tmp`, a scratch dir, a
  terminal), say so. If it is cheap to keep, offer to move it somewhere
  permanent.

**Record dead ends.** One line per approach that failed, with the reason. This
stops the next session from going down the same path.

**Keep it short.** A new session should be able to read it in two or three
minutes. Usually that's under ~150 lines. Background stays short. Detail goes
into the open work and the hard-won knowledge.

**Link instead of copying.** If a plan already exists elsewhere, such as
`jot/<task>/TASK.md`, an issue or a design doc, point to it and record only
what that source is missing. Note any updates it needs, or make them if the
user agrees.
