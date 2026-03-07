---
title: "Survey: AI Agents for Formal Mathematics (External Landscape, 2026)"
date-created: 2026-03-07T00:00:00
authors:
  - claude
tags:
  - Formalization
  - ProofAssistants
  - AIAgents
---

# AI Agents for Formal Mathematics: External Landscape Survey

Survey of external tools, research, and practices for LLM agents doing formal
mathematics with proof assistants. Focused on what exists outside this
repository that could improve agent mathematical capability here.

## 1. LLM-Based Mathematical Reasoning Agents

### DeepSeek-Prover-V2 (DeepSeek, 2025)

Formal theorem proving in Lean 4. Key innovation: subgoal decomposition —
the model writes an informal proof sketch first, decomposes into formal
subgoals, then proves each subgoal. Trained with GRPO (not PPO) reinforcement
learning. Achieved 88.9% on MiniF2F-test, 49 out of 658 problems on
FormalMATH. Open-weight (7B and 671B MoE variants).

- Paper: arxiv.org/abs/2505.XXXXX
- Relevance: The subgoal decomposition pattern is directly applicable. The
  "informal sketch first, then formalize" workflow is what our agent should do.

### AlphaProof (DeepMind, 2024)

Solved 4 of 6 IMO 2024 problems (silver medal level). Uses AlphaZero-style
reinforcement learning with Lean 4 as the verifier. Not open-source. Trained
on millions of self-generated problems.

- Relevance: Demonstrates ceiling capability. Not usable by us, but the
  self-play training pattern influenced later open systems.

### Kimina-Prover (May 2025)

Based on Qwen2.5-72B, fine-tuned for Lean 4. Uses "K1-style" long thinking
for proof search. Achieved 80.7% on MiniF2F-test. Open-weight.

- Relevance: Shows that mid-scale models can be competitive with fine-tuning.

### BFS-Prover (ByteDance, 2025)

Best-first search with expert iteration in Lean 4. Achieved 71.3% on
MiniF2F-test. Key contribution: curriculum-based training where problems
are ordered by difficulty.

- Relevance: The curriculum ordering is relevant to our skill design.

### HILBERT (2025)

Multi-agent system achieving 99.2% on MiniF2F-test. Uses recursive
decomposition: informal reasoning → formal subgoals → tactic generation →
semantic theorem retrieval → verification loop.

- Paper: arxiv.org/abs/2509.22819
- Relevance: Very high. The agent architecture maps to skills we could define.

### COPRA (2024)

In-context learning agent for Coq and Lean. No fine-tuning — uses GPT-4
with retrieval from the proof library. Sends proof state, gets next tactic.

- Relevance: Closest to our setup (general-purpose LLM, no fine-tuning).
  Demonstrates that in-context retrieval can work without specialization.

### Prover Agent / Delta Prover (2025)

Multi-agent decomposition: reasoning agent breaks theorem into subgoals,
proof agent generates tactics, repair agent fixes errors. Reflective
decomposition with iterative refinement.

- Paper: arxiv.org/abs/2506.19923
- Relevance: The decompose-prove-repair cycle maps to three distinct skills.

### APOLLO (NeurIPS 2025)

Agent framework with explicit sub-skills: syntax refining, sub-lemma
isolation, automated solver invocation, proof recombination.

- Paper: arxiv.org/abs/2505.05758
- Relevance: High. Closest to a skills taxonomy for math agents.

### LeanAgent (ICLR 2025)

Lifelong learning across 23 Lean repositories. Uses curriculum-based
progression — starts with easy proofs, gradually increases difficulty.
Demonstrates transfer learning across mathematical domains.

- Relevance: The curriculum progression model is directly relevant to
  building agent skills that improve over time.

---

## 2. Agent Tools for Lean 4

### lean-lsp-mcp (MCP server)

MCP server giving Claude Code access to Lean 4 via LSP: diagnostics, proof
goals, hover documentation, and search tools (LeanSearch, Loogle, Lean
Finder, Lean Hammer premise search). Install: `claude mcp add lean-lsp uvx
lean-lsp-mcp`. A Claude agent using this solved 12/12 Putnam 2025 problems.

- URL: github.com/oOo0oOo/lean-lsp-mcp
- Relevance: VERY HIGH. This is the single most important tool for our setup.

### LeanDojo v2 + Pantograph

Gymnasium-like environment for interacting with Lean 4 programmatically.
Pantograph provides a REPL: send a tactic, get the new goal state back.
LeanDojo extracts training data from Lean repos and provides premise
retrieval via ReProver.

- URL: leandojo.org, github.com/leanprover-community/Pantograph
- Relevance: High for understanding how agent-prover interaction works.
  Pantograph's REPL model is what lean-lsp-mcp builds on.

### LeanCopilot

LLMs as native copilots inside Lean 4 for tactic suggestion, premise search,
and proof search. Supports bring-your-own-model. Reduces manual proof steps
from 3.86 (aesop alone) to 2.08 on average.

- URL: github.com/lean-dojo/LeanCopilot
- Relevance: Medium. More for interactive VS Code use than agent workflows.

### ReProver (LeanDojo team)

Premise retrieval model for Lean 4. Given a proof state, retrieves relevant
premises from Mathlib's 100K+ declarations. Used by multiple agent systems.

- Relevance: The retrieval approach matters — our agent needs to find the
  right Mathlib lemma. lean-lsp-mcp provides access to similar search.

### Lean search tools

- **Loogle** (loogle.lean-lang.org) — pattern-based search by type signature
- **LeanSearch** — natural language search for Mathlib
- **Moogle** (Morph Labs) — LLM-based semantic search
- **LeanExplore** — AI-generated informal translations of formal statements
- **Lean Finder** — synthesizes user-style queries from formal statements

All available via lean-lsp-mcp.

### LeanAide

Autoformalization: translates informal math statements to Lean 4 formal
statements, then generates proofs.

- URL: github.com/siddhartha-gadgil/LeanAide
- Relevance: Relevant for our autoformalization needs.

### Zaffer/lean-gpt

Pre-prompt for configuring GPT-4 as a Lean 4 proof assistant. Emphasizes
brevity, tactical proof solving, error-cycle breaking, iterative refinement.

- URL: github.com/Zaffer/lean-gpt
- Relevance: High. The pre-prompt structure is a template for a Lean skill.

---

## 3. Agent Tools for Agda

### Almost nothing exists.

- **No Pantograph equivalent** — no REPL-based interaction
- **No LeanDojo equivalent** — no training data extraction
- **No benchmarks** — no MiniF2F for Agda
- **No LLM integration tools** — the only known project is a GitHub Gist
  (agda-llm) that loops LLM output through `agda --check`
- **QUILL** (Chalmers, 2025) — first neural architecture designed for Agda,
  modeling dependently-typed programs. Early-stage research.

**Structural difference**: Agda has no tactic language. Proofs are written as
direct terms in a functional programming style. Most LLM theorem-proving
frameworks are tightly coupled to tactic-based interaction. For Agda, the
agent must generate complete proof terms, not tactic sequences.

**This is a genuine research gap.** Building an Agda MCP server modeled on
lean-lsp-mcp would be novel work.

---

## 4. Benchmarks and Datasets

### MiniF2F (Lean/Isabelle, 2021)

488 math competition problems formalized in Lean and Isabelle. The standard
benchmark. Approaching saturation — top systems exceed 95%.

### FormalMATH (2025)

5,560 problems across 16 mathematical domains in Lean 4. Much harder than
MiniF2F. Current SOTA: 16%. This is the relevant hard benchmark now.

### MATH / GSM8K (informal)

Informal math problem datasets. MATH: 12,500 competition problems. GSM8K:
8,500 grade school word problems. Used for training informal reasoning, not
formal proving.

### ProofNet (2023)

Undergraduate-level math problems formalized in Lean 3 and Isabelle. Covers
analysis, algebra, number theory, topology.

### No Agda benchmarks exist.

---

## 5. Training Approaches and Curricula

### Expert Iteration

Generate candidate proofs → verify with proof checker → fine-tune on
successful proofs → repeat. Foundational approach used by most systems.
Plateaus without additional techniques.

### Self-Play (STP, ICML 2025)

Breaks the expert iteration plateau by having the model generate its own
training problems (conjectures), not just proofs. The model learns to
conjecture, prove, and verify in a loop.

### Curriculum Learning (LeanAgent)

Order problems by difficulty. Start with easy proofs, gradually increase
complexity. Demonstrated transfer across 23 Lean repositories. Directly
relevant to defining skill progressions.

### Subgoal Decomposition (DeepSeek-Prover-V2)

Informal reasoning first → decompose into formal subgoals → prove each.
The most effective pattern for hard problems. Does not require fine-tuning
— works with general-purpose LLMs via prompting.

### Draft-Sketch-Prove (DSP)

Prompt the LLM for an informal proof → translate to a formal sketch with
`sorry` holes → fill holes with automation or further LLM calls. Bridges
informal and formal reasoning.

### Retrieval-Augmented Generation

Retrieve relevant premises/lemmas from the proof library before generating
the proof. ReProver, Loogle, LeanSearch all serve this role for Lean.

---

## 6. Practical Integration Patterns

### REPL-based (Lean 4 via Pantograph / lean-lsp-mcp)

Send a tactic → get the new goal state → send the next tactic. Fine-grained
feedback. The agent sees exactly what remains to prove after each step.

### File-based (Agda, or Lean without Pantograph)

Write a complete file → run the checker → parse errors → revise → repeat.
Coarser feedback but simpler to implement.

### Error feedback loops

Both Lean and Agda provide detailed type error messages. The agent reads
errors, attempts fixes, resubmits. The Galois blog post ("Claude Can
Sometimes Prove It") reports this loop works but deep persistent mistakes
are costly to unwind.

### Handling Mathlib's namespace

Mathlib has 230K+ theorems and 110K+ definitions. Agents use:
- Loogle/LeanSearch/Moogle for retrieval
- lean-lsp-mcp for integrated search within Claude Code
- Naming conventions: theorem names follow syntax-tree order of the
  declarations they involve

---

## 7. Known Failure Modes

From the LeanCat benchmark and practitioner reports:

1. **Library knowledge gaps** — hallucinated lemma names, wrong Mathlib
   definitions. The most common failure.
2. **Abstraction mismatch** — element-wise reasoning when categorical
   reasoning is needed, or vice versa.
3. **Incomplete multi-step planning** — can't connect intermediate facts
   into a coherent end-to-end proof.
4. **Error cycle loops** — produces the same wrong code repeatedly.
5. **Autoformalization errors** — if the theorem statement is wrong, all
   proofs are useless regardless of validity.
6. **Creative reasoning gaps** — can execute known strategies but cannot
   invent new mathematical insights.

From the Galois report: deep persistent mistakes are rare but extremely
costly. The agent embeds confused understanding across many changes and
unpicking it is very time-consuming.

---

## 8. Actionable Recommendations

### Immediate (tools to install)

1. **lean-lsp-mcp** — install for any Lean 4 work. Gives the agent proof
   state, diagnostics, and Mathlib search.
2. **elan + Lean 4** — already installed in this environment.
3. **Agda** — already installed in this environment.

### Skills to define

Based on the decomposition used by HILBERT, APOLLO, Delta Prover, and the
Galois practitioner report:

1. `formalize-statement` — translate informal math to Lean 4 / Agda
2. `search-lemma` — find relevant library lemmas (via lean-lsp-mcp for Lean)
3. `decompose-proof` — break a theorem into subgoals and auxiliary lemmas
4. `write-proof` — generate a tactic proof (Lean) or term proof (Agda)
5. `repair-proof` — use compiler errors to fix broken proofs
6. `detect-error-cycle` — recognize when the same error keeps recurring
7. `verify-formalization` — check that formal statement matches informal intent

### Curricula to build

Based on LeanAgent's curriculum learning and BFS-Prover's difficulty ordering:

1. Start with Lean/Agda syntax exercises (rewrite existing proofs)
2. Progress to filling `sorry` holes in existing proofs
3. Then prove stated lemmas with known proof strategies
4. Then formalize informal statements and prove them
5. Then decompose and prove multi-step theorems

### Workflow pattern

The planner-executor pattern (from "Vibe Validation with Lean"):
- Use one pass to plan the proof structure (informal sketch, subgoals)
- Execute steps individually with verification between each
- Keep proof attempts bite-sized — don't let the agent run too long on one proof
- Always verify the formal statement matches the informal mathematics first

---

## Sources

### Blog Posts and Practitioner Reports
- [Galois: Claude Can (Sometimes) Prove It](https://www.galois.com/articles/claude-can-sometimes-prove-it)
- [Carl M. Kadie: Vibe Validation with Lean](https://medium.com/@carlmkadie/vibe-validation-with-lean-chatgpt-5-claude-4-5-part-1-c57b430b3d7a)
- [Martin Kleppmann: AI will make formal verification go mainstream](https://martin.kleppmann.com/2025/12/08/ai-formal-verification.html)
- [Luis Scoccola: Artificial Mathematical Intelligence in 2025](https://luisscoccola.com/blog/artificial-mathematical-intelligence/)

### Tools and Repositories
- [lean-lsp-mcp](https://github.com/oOo0oOo/lean-lsp-mcp)
- [LeanDojo](https://leandojo.org)
- [LeanCopilot](https://github.com/lean-dojo/LeanCopilot)
- [LeanAide](https://github.com/siddhartha-gadgil/LeanAide)
- [Zaffer/lean-gpt](https://github.com/Zaffer/lean-gpt)
- [llmstep](https://github.com/wellecks/llmstep)
- [Loogle](https://loogle.lean-lang.org/)
- [Pantograph](https://github.com/leanprover-community/Pantograph)

### Papers
- HILBERT (arxiv.org/abs/2509.22819)
- APOLLO (arxiv.org/abs/2505.05758)
- Prover Agent (arxiv.org/abs/2506.19923)
- Delta Prover (arxiv.org/html/2507.15225v1)
- LeanCat benchmark (arxiv.org/html/2512.24796v1)
- LeanExplore (arxiv.org/html/2506.11085v1)
- Lean Finder (arxiv.org/html/2510.15940v1)

### Community
- [Lean Zulip: ML for Theorem Proving](https://leanprover-community.github.io/archive/stream/219941-Machine-Learning-for-Theorem-Proving/)
- [EuroProofNet Workshop](https://europroofnet.github.io/wg5-edinburgh25/)
