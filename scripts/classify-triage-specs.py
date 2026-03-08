#!/usr/bin/env python3
"""Apply classifications from mining results to triage/specifications/ files.

One-time script — applies the inference results from the mining agent
to the frontmatter of each specification file.
"""

import re
import sys
from pathlib import Path

# Classifications from mining agent
CLASSIFICATIONS = {
    "activitypub.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "ActivityPub", "Federation"],
        "description": "Specification for simulating ActivityPub federation by routing ActivityStreams interactions through the relational knowledge graph and policy layers.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "audit.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Audit", "Provenance"],
        "description": "Specification for simulating provenance capture, trace reconstruction, and audit verification within the relational computer.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "baseline-renewal.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Trace", "Baseline", "Convergence"],
        "description": "Specification for simulating trace-tail convergence to a baseline limit with renewal and context transport mechanics.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "concurrency.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Concurrency", "Scheduling"],
        "description": "Specification for simulating safe concurrent execution of commuting operations within the relational computer.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "directed-homotopy.md": {
        "type": "specification",
        "tags": ["Mathematics", "Homotopy", "Directed", "Topology", "Simulation"],
        "description": "Specification for simulating directed homotopy via flow/nucleus operators and profile towers to compute reachable components.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "directed-stratified-site.md": {
        "type": "specification",
        "tags": ["Mathematics", "Site", "Stratification", "Coverage", "Topology"],
        "description": "Specification for simulating directed stratified sites with coverage computation, tower generation, and directed morphism validation.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "heyting-algebra.md": {
        "type": "specification",
        "tags": ["Mathematics", "Algebra", "Heyting", "Lattice", "Logic"],
        "description": "Specification for simulating a Heyting algebra of recognitions with lattice operations, implication, and consistency checks.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "index.md": {
        "type": "index",
        "tags": ["Index"],
        "description": "Index page for the simulation specifications directory.",
        "target-discipline": "technology",
        "triage-status": "superseded",
    },
    "infinity-site.md": {
        "type": "specification",
        "tags": ["Mathematics", "Site", "Infinity", "Coverage", "Sheaf"],
        "description": "Specification for simulating a directed infinity-site with objects, morphisms, covers, and tower hierarchy for sheafification.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "information-engine.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Pipeline", "Information", "Hypertensor"],
        "description": "Specification for the relational information engine: a five-stage pipeline turning raw payloads into structured information.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "intake-stack.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Intake", "Validation", "Pipeline"],
        "description": "Specification for simulating the intake stack that normalizes, validates, and contextualizes incoming observations.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "interface.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Interface", "API"],
        "description": "Specification for simulating the interface stack that exposes authenticated APIs dispatching through the relational computer.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "introspection.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Monitoring", "Introspection"],
        "description": "Specification for simulating the introspection stack that monitors module outputs and feeds anomaly alerts back into the system.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "knowledge-graph.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Knowledge", "RDF", "Graph"],
        "description": "Specification for simulating the relational knowledge graph with TracePoint-based resources, typed relations, and RDF/OWL import/export.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "markov-dynamics.md": {
        "type": "specification",
        "tags": ["Mathematics", "Markov", "Dynamics", "Kernel", "Entropy"],
        "description": "Specification for simulating Markov dynamics with kernel iteration, entropy monitoring, mixing tests, and detailed balance verification.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "measurement-algebra.md": {
        "type": "specification",
        "tags": ["Mathematics", "Measurement", "Algebra", "Observable"],
        "description": "Specification for simulating measurement algebra with observables, measures, integration, flow propagation, and equivalence classes.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "measurement-fabric.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Measurement", "Telemetry"],
        "description": "Specification for simulating the measurement fabric that captures, normalizes, and distributes observables across runtime modules.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "modal-logic.md": {
        "type": "specification",
        "tags": ["Mathematics", "Modal", "Logic", "Graph", "Topology"],
        "description": "Specification for simulating modal logic on state graphs with box/diamond operators, tower iteration, and KZ idempotence checks.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "modality-tower.md": {
        "type": "specification",
        "tags": ["Mathematics", "Modal", "Tower", "Temporal", "Logic"],
        "description": "Specification for simulating stacked modality towers with iterative modal operator application and stability detection.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "network.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Network", "Orchestration"],
        "description": "Specification for simulating the relational network orchestration layer with module routing, backpressure, and health monitoring.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "parametric-semantics.md": {
        "type": "specification",
        "tags": ["Mathematics", "Semantics", "Parametric", "Category"],
        "description": "Specification for simulating parametric semantics with indexed categories, effect/coeffect operators, and abstraction theorem enforcement.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "policy.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Policy", "Governance", "Audit"],
        "description": "Specification for simulating the policy stack that validates, enforces, and audits discipline/filter governance rules.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "quasicrystalline-hypertensor-sheaf-dynamics.md": {
        "type": "specification",
        "tags": ["Mathematics", "Hypertensor", "Sheaf", "Dynamics", "Markov"],
        "description": "Specification for simulating dynamics on the quasicrystalline hypertensor sheaf via local endomorphisms and Markov evolution.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "quasicrystalline-hypertensor-sheaf.md": {
        "type": "specification",
        "tags": ["Mathematics", "Hypertensor", "Sheaf", "Tower", "Universal"],
        "description": "Specification for simulating the quasicrystalline hypertensor sheaf with trace fibres, profile towers, and domain view projections.",
        "target-discipline": "mathematics",
        "triage-status": "classified",
    },
    "quasicrystalline-hypertensor.md": {
        "type": "specification",
        "tags": ["Mathematics", "Hypertensor", "Quasicrystal", "Substitution"],
        "description": "Specification for simulating quasicrystalline hypertensors with lattice windows, substitution dynamics, and aperiodicity verification.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "relational-free-quotient.md": {
        "type": "specification",
        "tags": ["Mathematics", "Algebra", "Free", "Quotient", "Normalization"],
        "description": "Specification for simulating free and quotient acts with syntax tree formation, reduction, and quotient construction.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "replication.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Replication", "Consistency"],
        "description": "Specification for simulating replication with update logging, distribution, and convergence-based consistency verification.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "scheduler.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Scheduling", "Execution"],
        "description": "Specification for simulating the scheduling stack with dependency-ordered task dispatch and failure handling.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "sheaf-topos.md": {
        "type": "specification",
        "tags": ["Mathematics", "Sheaf", "Topos", "Category", "Gluing"],
        "description": "Specification for simulating sheaf topos construction with sites, presheaves, matching families, and sheafification.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "spectral-theorem.md": {
        "type": "specification",
        "tags": ["Mathematics", "Spectral", "Harmonic", "Eigenvalue", "Kernel"],
        "description": "Specification for simulating spectral decomposition of the observation kernel into harmonic modes and projections.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "stlc.md": {
        "type": "specification",
        "tags": ["Mathematics", "Lambda", "TypeTheory", "Evaluation"],
        "description": "Specification for simulating a simply-typed lambda calculus evaluator with typing, reduction, and normalization checks.",
        "target-discipline": "mathematics",
        "triage-status": "promotable",
    },
    "storage.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Storage", "Persistence", "Snapshot"],
        "description": "Specification for simulating relational storage with snapshot save/load, context archives, and renewal-consistent persistence.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "testing.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Testing", "Verification"],
        "description": "Specification for simulating the testing harness with trace-based test cases and measurement-stack assertions.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "topology-integration.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Topology", "Scheduling", "Sheaf"],
        "description": "Specification for simulating topology integration that derives scheduling constraints and locality hints from tower and sheaf structures.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "traceability-graph.md": {
        "type": "specification",
        "tags": ["Computing", "Architecture", "Traceability", "Dependencies"],
        "description": "Specification for simulating the traceability graph that validates dependency DAGs with policy compliance.",
        "target-discipline": "technology",
        "triage-status": "promotable",
    },
    "universal-state.md": {
        "type": "specification",
        "tags": ["Mathematics", "Hypertensor", "Universal", "Tower", "State"],
        "description": "Specification for simulating the universal state as a hypertensor with trace fibres, profile towers, and domain views.",
        "target-discipline": "mathematics",
        "triage-status": "classified",
    },
}


def apply_classification(filepath, classification):
    """Add classification fields to existing frontmatter."""
    content = filepath.read_text(errors="replace")

    if not content.startswith("---"):
        return False, "no frontmatter"

    end = content.find("---", 3)
    if end < 0:
        return False, "malformed frontmatter"

    fm_text = content[3:end]
    body = content[end + 3:]

    # Build new fields to add
    additions = []
    for key in ["type", "description", "target-discipline", "triage-status"]:
        if key in classification and key + ":" not in fm_text:
            val = classification[key]
            if ":" in str(val) or str(val).startswith("["):
                additions.append(f'{key}: "{val}"')
            else:
                additions.append(f"{key}: {val}")

    if "tags" in classification and "tags:" not in fm_text:
        additions.append("tags:")
        for tag in classification["tags"]:
            additions.append(f"  - {tag}")

    if not additions:
        return False, "already classified"

    new_fm = fm_text.rstrip() + "\n" + "\n".join(additions) + "\n"
    new_content = f"---\n{new_fm}---\n{body}"
    filepath.write_text(new_content)
    return True, f"added {len([a for a in additions if not a.startswith('  -')])} fields"


def main():
    # Find content dir
    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parent

    for c in [repo_root / "content", repo_root.parent / "content"]:
        if (c / "triage" / "specifications").is_dir():
            specs_dir = c / "triage" / "specifications"
            break
    else:
        print("ERROR: Could not find content/triage/specifications/")
        sys.exit(1)

    print(f"Classifying files in: {specs_dir}\n")

    changed = 0
    for filename, classification in sorted(CLASSIFICATIONS.items()):
        filepath = specs_dir / filename
        if not filepath.exists():
            print(f"  SKIP {filename}: file not found")
            continue

        success, msg = apply_classification(filepath, classification)
        if success:
            changed += 1
            print(f"  OK   {filename}: {msg}")
        else:
            print(f"  SKIP {filename}: {msg}")

    print(f"\nClassified {changed} files")


if __name__ == "__main__":
    main()
