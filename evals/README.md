# Eval suite

Two groups, run from the plugin root with `claude plugin eval`.

- `edit/`: 19 scaffolded repositories. Each case has a `fixture.sh` that builds the repo (git initialised, one commit, a plain-Node `gate.js`), a ticket in `prompt.md`, deterministic graders (regex on file contents, `tool_used`, `file_exists`), a `README.md` naming what each grader proves, and `reference/ANSWER.md` with a human-written passing change. Run with `--scaffold --allow-tools Bash Edit Write`.
- `reply/`: 12 temptation tickets answered in prose with inline code, judged by a model (`--judge-model sonnet`); graders judge the code in the answer, never its wording.

Five runs per arm is the minimum that separates an effect from run-to-run swing (single runs move 2 to 6 points at temperature 0):

    claude plugin eval . --eval-dir evals/edit --scaffold --allow-tools Bash Edit Write --ablation with-without --runs 5 --no-publish --report
    claude plugin eval . --eval-dir evals/reply --ablation with-without --runs 5 --judge-model sonnet --no-publish --report

Decision rule used for releases: a change ships only when no case loses on a code grader against the current text and it adds no turns without a grader gain.
