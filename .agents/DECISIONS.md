# Decision Log

Append-only. Newest at the bottom. One entry per decision with context + rationale.

## 2026-08-12 — Project Context Gate (Layer 1b, repo-side)

- **Context:** Multiple agents (Hermes, OpenCode, OpenAgents) operate this repo; sessions
  drifted because context was only read from memory, not from the repo.
- **Decision:** Mandatory gate: read `context/governance.md` + logs before any plan/action,
  write context after any state change. Approved 2026-08-12 (ACTIVE).
- **Rationale:** Deterministic repo-side context beats agent memory; the gate is the
  single enforced entry point.
- **Alternatives:** Rely on agent descriptions/KB only (rejected — not repo-bound).

## 2026-08-20 — Adopt .agents/ standard folder

- **Context:** Workspace-wide standardization on `AGENTS.md` + `.agents/` (see
  multi-agent-project-context standard).
- **Decision:** Add `.agents/` (README/PROJECT/ARCHITECTURE/CONVENTIONS/DECISIONS/memory/docs)
  + platform shims. Root AGENTS.md stays the gate entry; `context/` (non-dot) is untouched —
  it holds real operational content, not agent context.
- **Rationale:** Consistency across all repos; shims make Claude Code/Gemini/Aider read AGENTS.md.
- **Alternatives:** Moving `context/` into `.agents/` (rejected — it is operational content,
  and the gate protocol + OpenAgents skills reference `context/` paths).
