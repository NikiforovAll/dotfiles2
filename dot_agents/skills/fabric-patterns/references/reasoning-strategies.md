# Reasoning Strategies Reference

Reasoning strategies in Fabric act as "wrappers" that sit around your chosen pattern or raw input. They force the model to follow specific cognitive architectures before providing a final answer.

## Core Reasoning Models

| Strategy | Full Name | Approach | Best For |
| :--- | :--- | :--- | :--- |
| `cot` | Chain-of-Thought | Sequential logical steps | Math, planning, logic puzzles |
| `tot` | Tree-of-Thought | Parallel branching paths | Creative writing, strategic planning |
| `aot` | Atom-of-Thought | Decomposition into atomic parts | Coding, proofs, verifiable tasks |
| `cod` | Chain-of-Draft | Iterative drafting/refinement | Long-form content, essays |

## Evaluation & Refinement

| Strategy | Full Name | Approach | Best For |
| :--- | :--- | :--- | :--- |
| `reflexion` | Reflexion | Self-critique and error correction | Code debugging, quality review |
| `self-refine` | Self-Refinement | Iterative self-improvement | Polishing drafts, creative work |
| `self-consistent` | Self-Consistency | Multiple attempts + consensus | High-precision factual tasks |

## Task-Specific Strategies

| Strategy | Full Name | Approach | Best For |
| :--- | :--- | :--- | :--- |
| `ltm` | Least-to-Most | Simple to complex sub-problems | Educational tasks, multi-part problems |
| `standard` | Standard | Direct response | Simple queries, fast summaries |

## Detailed Strategy Breakdown

### Chain-of-Thought (`cot`)
- **How it works:** Instructs the model to "think out loud" step-by-step.
- **Why use it:** Greatly reduces "hallucinations" in logic and math by making the intermediate steps explicit.

### Tree-of-Thought (`tot`)
- **How it works:** The model considers multiple potential directions, evaluates them, and selects the most promising path.
- **Why use it:** Perfect when there isn't one "correct" first step, or when you need a diversity of ideas before narrowing down.

### Atom-of-Thought (`aot`)
- **How it works:** Breaks a large problem into completely independent sub-tasks that could theoretically be solved in isolation.
- **Why use it:** Essential for complex software engineering where you need to define interfaces, data structures, and logic separately but cohesively.

### Reflexion (`reflexion`)
- **How it works:** The model generates a response, then critiques it for flaws, then generates a final response based on that critique.
- **Why use it:** When "first draft" quality isn't enough and you need the model to "check its own work."

## Strategy Selection Guide

| If the task is... | Use Strategy |
| :--- | :--- |
| "I need to solve this complex equation" | `cot` |
| "I need to architect a new microservice" | `aot` |
| "I need 5 different story angles for a blog" | `tot` |
| "I need this code to be absolutely bug-free" | `reflexion` |
| "I need the most accurate fact check possible" | `self-consistent` |
