---
name: nlspec
description: Use when writing specs for development plans. Provides a natural language specification markdown dialect.
user-invocable: false
---

# NLSpec: Natural Language Specification Format

A specification for writing human-readable, machine-actionable software specifications (NLSpecs) that coding agents can directly use to implement and validate behavior. This document is itself an NLSpec -- it follows the conventions it defines.

---

## Table of Contents

1. [Overview and Goals](#1-overview-and-goals)
2. [Document Structure](#2-document-structure)
3. [Pseudocode Language](#3-pseudocode-language)
4. [Requirement Language](#4-requirement-language)
5. [Tables and References](#5-tables-and-references)
6. [Examples and Diagrams](#6-examples-and-diagrams)
7. [Definition of Done](#7-definition-of-done)
8. [Appendices](#8-appendices)
9. [Definition of Done (This Spec)](#9-definition-of-done-this-spec)

---

## 1. Overview and Goals

### 1.1 Problem Statement

Software specifications traditionally serve one of two audiences: humans (who read prose descriptions and make judgment calls) or machines (who consume formal grammars, IDL files, or OpenAPI schemas). Neither format works well for AI coding agents. Prose specs are ambiguous -- two developers reading the same paragraph may implement different behaviors. Formal specs are precise but opaque -- they define syntax without conveying intent, rationale, or validation criteria.

NLSpec bridges this gap. An NLSpec is a Markdown document written in structured natural language with embedded pseudocode, attribute tables, and a checkable Definition of Done. A competent coding agent can read an NLSpec and implement the described system from scratch, including validation logic, without ambiguity about intended behavior. A human can read the same document and understand the design, rationale, and scope.

### 1.2 What NLSpec Is

An NLSpec (Natural Language Spec) is a human-readable specification intended to be directly usable by coding agents to implement and validate behavior. It is:

- **A Markdown document.** Standard GitHub-Flavored Markdown. No custom syntax. Renderable in any Markdown viewer.
- **Language-agnostic.** All code is pseudocode. Data structures use neutral notation. No specific programming language is assumed or required.
- **Self-contained.** One spec per file. Each file describes a complete, implementable system or component. Cross-references to companion specs are explicit.
- **Actionable.** Every spec ends with a Definition of Done section containing checkboxes that an implementor (human or agent) can verify. The spec is done when every box is checked.

### 1.3 What NLSpec Is Not

- **Not a formal grammar.** NLSpec is not BNF, Protocol Buffers, or OpenAPI. It may contain formal grammars as embedded elements, but the overall document is structured prose.
- **Not code.** The pseudocode in an NLSpec is not executable. It communicates algorithms and data structures without prescribing a language.
- **Not a tutorial.** NLSpecs assume the reader is a competent developer or a capable coding agent. They do not teach fundamentals.
- **Not a requirements document.** NLSpecs describe what to build and how it should behave, not why a product decision was made. Business context belongs elsewhere (though design rationale is included).

### 1.4 Design Principles

**Precision without formalism.** NLSpecs use structured natural language -- numbered sections, typed pseudocode, attribute tables, and explicit constraints -- to achieve the precision of a formal spec while remaining readable. Where formalism adds clarity (BNF grammars, type signatures), use it. Where prose is clearer, use prose.

**Implementable from scratch.** A developer or coding agent reading an NLSpec should be able to implement the described system in any programming language without consulting external documentation. All necessary information -- data structures, algorithms, edge cases, validation rules -- is in the document.

**Checkable completeness.** Every NLSpec ends with a Definition of Done: a flat checklist of observable behaviors. An implementation is complete when every item is checked. This transforms "is it done?" from a subjective judgment into a verifiable test.

**Rationale is documentation.** Design decisions are documented with their reasoning. This prevents implementors from second-guessing constraints that exist for good reasons, and helps them make informed tradeoffs when their language or context demands adaptation.

**Layered detail.** Specs progress from high-level overview to detailed behavior. A reader can stop at Section 1 and understand the purpose, stop at the end of the core sections and understand the architecture, or read through the appendices for every edge case.

### 1.5 Audience

NLSpecs have two primary audiences:

1. **Coding agents.** AI systems (Claude Code, Codex, Gemini CLI, Cursor, etc.) that read the spec and produce a working implementation. The spec must be unambiguous enough that the agent does not need to make design decisions beyond language-specific idioms.

2. **Human developers.** Engineers who review, maintain, or extend the implementation. The spec must be readable enough that a human can understand the intended behavior, verify an implementation against it, and make informed changes.

The format is optimized for the first audience (coding agents) while remaining natural for the second (humans). When there is tension between the two, favor explicitness over brevity.

---

## 2. Document Structure

### 2.1 File Format

An NLSpec is a single Markdown file using GitHub-Flavored Markdown (GFM). The file extension is `.md`. One spec per file. The file name should be descriptive and use kebab-case: `my-system-spec.md`.

### 2.2 Required Sections

Every NLSpec must contain the following top-level sections in this order:

```
# Title                                    -- H1: the spec name
(opening paragraph)                        -- 1-2 sentences: what this spec describes
---                                        -- horizontal rule
## Table of Contents                       -- numbered list with anchor links
---                                        -- horizontal rule
## 1. Overview and Goals                   -- why this system exists
## 2-N. Core Sections                      -- the spec body (varies per document)
## N+1. Definition of Done                 -- checkable completeness criteria
---                                        -- horizontal rule
## Appendix A: ...                         -- supplementary material (optional)
## Appendix B: ...
```

The Definition of Done is always the last numbered section. Appendices may appear either before or after the Definition of Done, depending on the author's preference. When appendices contain reference material that supports the DoD (e.g., complete attribute tables needed for verification), placing them before the DoD can be convenient. When the DoD is intended as the final "are we done?" checklist, placing it after appendices puts it at the end of the document for easy access.

### 2.3 Title and Opening Paragraph

The document begins with a single H1 title, followed by a one-to-two sentence paragraph that states:
1. What the spec describes
2. Optionally, that it is language-agnostic and/or implementable from scratch (when applicable)

```
# Unified LLM Client Specification

This document is a consolidated, language-agnostic specification for building
a unified client library that provides a single interface across multiple LLM
providers. It is designed to be implementable from scratch by any developer
or coding agent in any programming language.
```

The opening paragraph is immediately followed by a horizontal rule (`---`).

### 2.4 Table of Contents

A numbered list of all top-level sections with anchor links. The Table of Contents uses Markdown heading anchors:

```
## Table of Contents

1. [Overview and Goals](#1-overview-and-goals)
2. [Architecture](#2-architecture)
3. [Data Model](#3-data-model)
...
N. [Definition of Done](#n-definition-of-done)
```

Appendices are not listed in the Table of Contents. The Table of Contents is followed by a horizontal rule.

### 2.5 Section Numbering

Sections use decimal numbering at two levels:

- **Top-level sections:** `## 1. Section Name` (H2 with number prefix)
- **Subsections:** `### 1.1 Subsection Name` (H3 with decimal number prefix)

Deeper nesting (H4, H5) is allowed for sub-subsections but does not use numbering. Bold text or inline headings are preferred for fine-grained structure within a subsection.

Numbering is continuous across the document. Section 1 is always "Overview and Goals". The last numbered section is always "Definition of Done".

### 2.6 Horizontal Rules

Horizontal rules (`---`) are used as visual separators:

- After the opening paragraph
- After the Table of Contents
- Between each top-level section (between sections at the `##` level)
- Before the first appendix

### 2.7 Overview and Goals Section

Section 1 is always "Overview and Goals" and must contain:

**Problem Statement** (typically 1.1) -- What problem this system solves. Written as 1-2 paragraphs explaining the pain point. This grounds the reader in the "why" before the "what." Must appear before Design Principles.

**Design Principles** -- 3-7 guiding principles, each formatted as a bold keyword followed by a description paragraph. Typically 1.2, but may appear at a later subsection number when additional subsections (such as "Why X" justifications or architecture overviews) are interleaved before it:

```
**Principle name.** Description of the principle and what it means
for the implementation. One paragraph per principle.
```

Design principles serve as a decision framework. When an implementor faces an ambiguous choice, the principles should guide the decision.

**Optional subsections** that may appear in the Overview:

- **Why X** -- Justification for a key technology or approach choice (e.g., "Why DOT Syntax", "Why a Library, Not a CLI")
- **Reference Projects** -- Real-world open-source projects that solve related problems, with URLs and short descriptions of what to study in each
- **Layering and Dependencies** -- How this spec relates to companion specs or external systems
- **Architecture** -- A high-level diagram or description of the system's structure

### 2.8 Core Sections

Sections 2 through N-1 contain the specification body. The number and names of core sections vary by document. Common section types include:

- **Data Model / Schema** -- Types, records, enums used by the system
- **Algorithm / Engine** -- Core execution logic in pseudocode
- **Interfaces / Contracts** -- Interfaces that implementations must satisfy
- **Configuration** -- Attributes, settings, and their defaults
- **Extensibility** -- Plugin points, custom handlers, middleware
- **Validation** -- Rules for checking correctness

Each core section follows the pattern: explain the concept in prose, then define it precisely with pseudocode, tables, or formal grammar.

### 2.9 Definition of Done Section

Always the last numbered section. May appear before or after appendices (see Section 2.2). Contains:

1. **Grouped checklists** -- Subsections (e.g., "### N.1 Core Loop", "### N.2 Provider Adapters") each containing a flat list of checkbox items (`- [ ]`).

2. **Cross-feature parity matrix** -- A table where rows are test cases and columns are variants (e.g., providers, configurations). Each cell contains `[ ]`.

3. **Integration smoke test** -- A pseudocode end-to-end test with `ASSERT` statements that exercises the complete system.

See Section 7 for full details.

### 2.10 Appendices

Appendices are lettered sections (`## Appendix A: Title`), separated from adjacent sections by horizontal rules. They contain supplementary material that supports but is not essential to the core spec. Appendices may appear either before or after the Definition of Done (see Section 2.2):

- **Complete attribute references** -- exhaustive tables consolidating all attributes from the core sections
- **Format references** -- detailed grammar or format definitions (e.g., patch format, status file contract)
- **Design decision rationale** -- "Why X" explanations for all major design choices, collected in one place
- **Usage examples** -- code examples showing common patterns
- **Error handling details** -- categorization of error types and recovery strategies

Appendices are referenced from the core sections where relevant (e.g., "See Appendix A for the complete format reference").

---

## 3. Pseudocode Language

### 3.1 Purpose

NLSpec pseudocode communicates algorithms, data structures, and interfaces without prescribing a programming language. It is meant to be read and translated by both humans and coding agents into any target language.

### 3.2 Data Structures

#### Records

Records define named data structures with typed fields:

```
RECORD Name:
    field_name    : Type              -- description
    another_field : Type = default    -- description with default value
    optional_one  : Type | None       -- nullable/optional field
```

**Inheritance.** Records may extend a parent type using `extends`:

```
RECORD ChildType extends ParentType:
    extra_field   : Type              -- fields specific to the child
```

Inheritance indicates that the child type has all fields of the parent plus its own additional fields. This is commonly used for error hierarchies and type taxonomies.

The `RECORD` keyword is optional. When context makes the construct clear, bare `Name:` syntax is equivalent:

```
Name:
    field_name    : Type              -- description
    another_field : Type = default    -- description with default value
```

Field declarations use the pattern `name : Type`. Alignment of colons is encouraged for readability. Comments explaining fields use `--` and are right-aligned.

Records may also contain `PROPERTY` declarations (computed or derived values) and `FUNCTION` definitions when describing types that combine state and behavior. When a record includes functions, it overlaps with implementation blocks (see below); the `RECORD` keyword emphasizes the data structure aspect while implementation blocks emphasize behavior.

#### Interfaces

Interfaces define contracts that implementations must satisfy:

```
INTERFACE Name:
    PROPERTY prop_name : Type

    FUNCTION method_name(param: Type) -> ReturnType
        -- Description of what this method does

    FUNCTION another_method(param: Type, optional: Type | None) -> ReturnType
```

Interfaces contain property declarations and function signatures. Implementation details go in the describing prose, not in the interface definition.

#### Enums

Enumerations define named constants:

```
ENUM Name:
    VALUE_ONE       -- description
    VALUE_TWO       -- description
    VALUE_THREE     -- description
```

The `ENUM` keyword is optional. Bare `Name:` syntax is equivalent when the block contains only constant values. Alternatively, enums with string-literal alternatives may use BNF-style notation inline:

```
FidelityMode ::= 'full' | 'truncate' | 'compact' | 'summary:low' | 'summary:medium' | 'summary:high'
```

Enum values are UPPER_SNAKE_CASE (for symbolic constants) or lowercase quoted strings (for literal alternatives). Descriptions use `--` comments.

#### Implementation Blocks

Implementation blocks define concrete implementations that combine state (fields) and behavior (functions). They use bare `Name:` syntax and typically implement an interface:

```
ConcreteHandler:
    backend : SomeBackend | None    -- field declaration

    FUNCTION execute(node, context, graph, logs_root) -> Outcome:
        -- implementation logic
        RETURN Outcome(status=SUCCESS)
```

Implementation blocks are distinguished from records by the presence of `FUNCTION` definitions alongside field declarations. They are distinguished from interfaces by containing concrete logic rather than just signatures. The bare `Name:` syntax (without a keyword) is the canonical form for implementations.

#### Tool Definitions

Tool definitions describe tool or API interfaces with structured metadata fields:

```
TOOL tool_name:
    description: "What this tool does"
    parameters:
        param_name     : Type (required)     -- description
        other_param    : Type (optional)     -- description with constraint annotation
    returns: Description of return value
    errors: Error conditions (comma-separated list or prose)
```

The `TOOL` keyword introduces a named tool interface. Parameters use `(required)` and `(optional)` annotations to indicate whether the parameter must be provided. The `returns:` and `errors:` fields describe the tool's output contract and failure modes in prose. Default values for optional parameters may also be noted inline (e.g., `limit : Integer (optional) -- max lines to read (default: 2000)`).

Tool definitions are used when a spec defines tools that an LLM or agent can invoke. They differ from `FUNCTION` definitions in that they describe an external interface (with human-readable descriptions and error documentation) rather than an algorithm.

### 3.3 Functions

Functions define algorithms:

```
FUNCTION name(param1: Type, param2: Type = default) -> ReturnType:
    -- Description or comment
    statements
    RETURN value
```

Function parameters use `name: Type` syntax. Default values use `= value`. Return type is declared with `-> Type`. Functions without a meaningful return value omit the return type annotation.

**Bare function signatures.** When documenting an API surface or lookup functions (rather than defining an algorithm), the `FUNCTION` keyword may be omitted. Bare signatures list the function name, parameters, return type, and a `--` comment:

```
get_model_info(model_id: String) -> ModelInfo | None
    -- Returns the catalog entry for a model, or None if unknown.

list_models(provider: String | None) -> List<ModelInfo>
    -- Returns all known models, optionally filtered by provider.
```

Bare signatures are appropriate in code blocks that enumerate an API surface. When defining an algorithm with implementation logic, use the full `FUNCTION` keyword.

### 3.4 Type System

The pseudocode uses these built-in types:

| Type            | Meaning                                        |
|-----------------|------------------------------------------------|
| `String`        | Text data                                      |
| `Integer`       | Whole number                                   |
| `Float`         | Decimal number                                 |
| `Boolean`       | `true` or `false`                              |
| `Bytes`         | Raw binary data                                |
| `Timestamp`     | Point in time                                  |
| `Duration`      | Time interval                                  |
| `Any`           | Any type (use sparingly)                       |
| `Void`          | No return value                                |
| `NONE`          | Null / nil / absent value                      |

**Composite types:**

| Syntax                 | Meaning                                     |
|------------------------|---------------------------------------------|
| `List<T>`              | Ordered collection of T                     |
| `Map<K, V>`            | Key-value mapping                           |
| `Dict`                 | Shorthand for `Map<String, Any>`            |
| `Queue<T>`             | FIFO queue of T                             |
| `Set<T>`               | Unordered unique collection of T            |
| `T \| None`            | Optional (nullable) value                   |
| `T \| U`               | Union / either type                         |
| `(T, U)`               | Tuple                                       |
| `Function(T) -> U`     | Callable / function type                    |
| `AsyncIterator<T>`     | Asynchronous iterator over T                |

### 3.5 Control Flow

All control flow keywords are UPPER_CASE:

```
-- Conditional
IF condition:
    statements
ELSE IF other_condition:
    statements
ELSE:
    statements

-- Loops
FOR EACH item IN collection:
    statements

FOR i FROM start TO end:
    statements

FOR i FROM start TO end STEP increment:
    statements

WHILE condition:
    statements

LOOP:
    statements
    IF exit_condition:
        BREAK

-- Loop control
BREAK                   -- exit the innermost loop
CONTINUE                -- skip to the next iteration

-- Error handling
TRY:
    statements
CATCH exception:
    statements

RAISE "error message"
RAISE ErrorType("message")

-- Return
RETURN value

-- Yield (for generators and iterators)
YIELD value                 -- produce a value and suspend
YIELD event                 -- common in streaming/iterator patterns

-- Test assertions (used in Definition of Done smoke tests)
ASSERT condition            -- verify that a condition is true
FAIL("message")             -- force a test failure with a message
PASS                        -- explicit no-op (test passes)

-- State transitions (for documenting state machines)
STATE_A -> STATE_B          -- condition or trigger
```

**Explicit end markers.** NLSpec pseudocode uses indentation-based blocks by default. However, when a block is long or deeply nested, an explicit end marker (e.g., `END LOOP`, `END IF`, `END FUNCTION`) may be used for clarity. End markers are optional -- indentation alone is always sufficient, but explicit markers are acceptable when they improve readability.

**State transition notation.** State machines may be documented using arrow notation (`STATE_A -> STATE_B -- condition`). State names are UPPER_CASE or PascalCase. Transitions are listed one per line with `--` comments describing the trigger. This notation appears in fenced code blocks alongside other pseudocode constructs.

### 3.6 Expressions and Operators

```
-- Comparison
a == b                  -- equality
a != b                  -- inequality
a > b, a < b            -- ordering
a >= b, a <= b          -- ordering
a IN collection         -- membership
a IS Type               -- type check
value is NONE           -- null check
value is not NONE       -- non-null check

-- Boolean
a AND b
a OR b
NOT a

-- Arithmetic
a + b                   -- addition (also string concatenation)
a - b                   -- subtraction
a * b                   -- multiplication
a / b                   -- division
a % b                   -- modulo
a ^ b                   -- exponentiation

-- Assignment
x = value               -- assignment
x += value              -- compound assignment

-- Access
object.field            -- property access
collection[index]       -- indexing
collection[start..end]  -- slicing (exclusive end)
collection[-N..]        -- last N elements
```

### 3.7 Common Operations

```
-- Collection operations
LENGTH(collection)                  -- size/length
collection.APPEND(item)             -- add to end
collection.get(key, default)        -- dictionary lookup with default
collection.DEQUEUE()                -- remove from front (queue)

-- String operations
str(value)                          -- convert to string
trim(string)                        -- strip whitespace
replace(string, old, new)           -- string replacement
split(string, delimiter)            -- split into list
lowercase(string)                   -- to lowercase

-- Concurrency
AWAIT expression                    -- await async result
AWAIT_ALL(list_of_futures)          -- await all concurrent operations

-- Utility
MIN(a, b)                           -- minimum
MAX(a, b)                           -- maximum
ROUND(value)                        -- rounding
RANDOM(min, max)                    -- random number in range
NOW()                               -- current timestamp

-- Logging
LOG(message)                        -- log a message
PRINT(message)                      -- output to console
```

### 3.8 Comments

Comments use `--` (double dash) prefix:

```
-- This is a line comment

x = 42  -- This is an inline comment

-- Multi-line comments span multiple
-- consecutive comment lines
```

The `--` comment style is deliberately language-neutral (not `//`, `#`, or `/* */`).

### 3.9 Pseudocode Style Guidelines

- **Indentation-based blocks.** No curly braces. Block boundaries are determined by indentation (similar to Python). Use consistent indentation (4 spaces recommended).
- **UPPER_CASE keywords.** All pseudocode keywords (`FUNCTION`, `IF`, `RETURN`, `FOR EACH`, etc.) are capitalized to distinguish them from identifiers.
- **snake_case identifiers.** Variable names, function names, and field names use snake_case.
- **PascalCase types.** Type names, record names, interface names, and enum names use PascalCase.
- **UPPER_SNAKE_CASE constants.** Enum values and named constants use UPPER_SNAKE_CASE.
- **Alignment.** Align field type annotations and comments within a record for readability.
- **Brevity over completeness.** Pseudocode should communicate the algorithm, not handle every edge case. Edge cases are documented in prose surrounding the pseudocode.

---

## 4. Requirement Language

### 4.1 Imperative Keywords

NLSpecs prefer plain English requirement keywords over the RFC 2119 capitalized convention. The intent is the same but the tone is less legalistic. Uppercase variants (`MUST`, `SHOULD`, `MUST NOT`) are acceptable when emphasis is needed, particularly in handler contracts or critical invariants:

| Keyword         | Meaning                                                        |
|-----------------|----------------------------------------------------------------|
| `must`          | Absolute requirement. The implementation is non-conformant without this. |
| `must not`      | Absolute prohibition.                                          |
| `should`        | Strong recommendation. Deviation requires a documented reason. |
| `should not`    | Strong discouragement. Deviation requires a documented reason. |
| `may`           | Truly optional. The implementation can include or omit this.   |

When a requirement is particularly critical, it may be emphasized with bold text, a section title annotation (e.g., "### 2.10 Prompt Caching (Critical for Cost)"), or an inline callout.

### 4.2 Emphasis Conventions

**Bold text** is used for:
- Design principle names (e.g., **Declarative pipelines.**)
- Key differences between approaches (e.g., **Key difference: `apply_patch` replaces `edit_file`**)
- Critical warnings (e.g., **This is a fundamental design requirement.**)
- Important behavioral notes (e.g., **Tool execution pipeline:**)

**Inline code** (backtick) is used for:
- Type names, field names, function names, and variable names
- Literal string values
- File names and paths
- Command names

### 4.3 Scoping Phrases

NLSpecs use specific phrases to scope requirements:

- **"The implementation..."** -- what the code must do
- **"The engine..."** / **"The handler..."** -- what a specific component must do
- **"The adapter..."** -- what a provider integration must do
- **"Applications..."** / **"Callers..."** / **"Consumers..."** -- what users of the API may do
- **"Implementations may..."** -- optional extension points

### 4.4 Out of Scope Declarations

Features intentionally excluded from the spec are documented in a dedicated section or subsection (typically titled "Out of Scope" or "Nice-to-Haves"). This may be a subsection within a core section or a standalone top-level numbered section before the Definition of Done. Each excluded feature gets:

1. **Name in bold.** What the feature is.
2. **Brief description.** What it would do.
3. **Extension point.** Where in the architecture it could be added later.

This prevents implementors from adding unnecessary features while showing that the omission was deliberate.

---

## 5. Tables and References

### 5.1 Attribute Reference Tables

Attribute tables define configuration surfaces (node attributes, edge attributes, request fields, etc.). They use this column structure:

| Column      | Purpose                                                    |
|-------------|------------------------------------------------------------|
| Key / Name  | The attribute or field identifier                          |
| Type        | The data type (using the pseudocode type system)           |
| Default     | The default value if unset                                 |
| Description | What the attribute controls                                |

Example:

```
| Key           | Type     | Default   | Description                          |
|---------------|----------|-----------|--------------------------------------|
| `max_retries` | Integer  | `0`       | Number of additional retry attempts  |
| `timeout`     | Duration | unset     | Maximum execution time for this node |
| `goal_gate`   | Boolean  | `false`   | Must succeed before pipeline exit    |
```

Backticks around keys and defaults are used to indicate literal values.

### 5.2 Mapping Tables

Mapping tables show how values translate between systems (e.g., provider-specific formats, shape-to-handler mappings):

```
| Shape        | Handler Type    | Description              |
|--------------|-----------------|--------------------------|
| `Mdiamond`   | `start`         | Pipeline entry point     |
| `Msquare`    | `exit`          | Pipeline exit point      |
| `box`        | `codergen`      | LLM task (default)       |
```

### 5.3 Comparison Tables

Comparison tables show how different implementations handle the same concept:

```
| Concern              | OpenAI                 | Anthropic              | Gemini               |
|----------------------|------------------------|------------------------|----------------------|
| System messages      | `instructions` param   | `system` parameter     | `systemInstruction`  |
| Tool results         | Separate `tool` msgs   | Blocks in user msg     | In user content      |
```

### 5.4 Enum Value Tables

Enum value tables document the meaning of each value in an enumeration:

```
| Status             | Meaning                                                  |
|--------------------|----------------------------------------------------------|
| `SUCCESS`          | Stage completed. Proceed to next edge. Reset retries.    |
| `FAIL`             | Stage failed permanently. Look for fail edge.            |
| `RETRY`            | Stage requests re-execution. Increment retry counter.    |
```

### 5.5 Cross-References

Sections reference each other using parenthetical cross-references:

```
The handler interface (Section 4.1) defines the contract.
Edge selection follows the priority algorithm (see Section 3.3).
See Appendix A for the complete format reference.
```

Cross-references to companion specs use the full file name:

```
This spec layers on top of the [Unified LLM Client Specification](./unified-llm-spec.md).
```

---

## 6. Examples and Diagrams

### 6.1 Inline Code Examples

Code examples are placed in fenced code blocks immediately after the prose that introduces them. Examples should be minimal -- just enough to illustrate the concept:

````
**Simple linear workflow:**

```
digraph Simple {
    graph [goal="Run tests and report"]
    start [shape=Mdiamond]
    exit  [shape=Msquare]
    run_tests [label="Run Tests", prompt="Run the test suite"]
    start -> run_tests -> exit
}
```
````

### 6.2 Pseudocode Algorithm Blocks

Core algorithms are presented as named `FUNCTION` blocks in fenced code blocks. The surrounding prose explains the algorithm's purpose, and the pseudocode defines its behavior:

````
The following pseudocode defines the edge selection algorithm:

```
FUNCTION select_edge(node, outcome, context, graph):
    edges = graph.outgoing_edges(node.id)
    IF edges is empty:
        RETURN NONE
    -- ... algorithm steps ...
    RETURN best_edge
```
````

### 6.3 BNF Grammars

When a spec defines a formal syntax (DSL, expression language, stylesheet grammar), use BNF-style grammar notation in a fenced code block:

````
```
Stylesheet    ::= Rule+
Rule          ::= Selector '{' Declaration ( ';' Declaration )* ';'? '}'
Selector      ::= '*' | '#' Identifier | '.' ClassName
Declaration   ::= Property ':' PropertyValue
```
````

BNF grammars appear in their own subsection (e.g., "### 2.2 BNF-Style Grammar") and are followed by a prose explanation of the key constraints.

### 6.4 ASCII Architecture Diagrams

System architecture is illustrated with ASCII box diagrams in fenced code blocks:

````
```
+--------------------------------------------------+
|  Host Application (CLI, IDE, Web UI)              |
+--------------------------------------------------+
        |                            ^
        | submit(input)              | events
        v                            |
+--------------------------------------------------+
|  Core Engine                                      |
|  +--------------------+  +---------------------+ |
|  | Component A        |  | Component B         | |
|  +--------------------+  +---------------------+ |
+--------------------------------------------------+
```
````

Use `+`, `-`, `|` for box borders, `v` and `^` for arrows, and label connections with descriptive text.

#### Hierarchy Tree Diagrams

Type hierarchies and inheritance trees are illustrated using `+--` for branches and `|` for vertical connectors:

````
```
BaseType
 +-- ChildTypeA                     -- description
 |    +-- GrandchildType            -- description
 |    +-- AnotherGrandchild         -- description
 +-- ChildTypeB                     -- description
 +-- ChildTypeC                     -- description
```
````

This notation is especially useful for error hierarchies, type taxonomies, and any inheritance structure where the relationships are clearer in tree form than as individual `extends` declarations.

### 6.5 Translation Mapping Notation

When a spec describes how one system's concepts map to another's (e.g., how a unified SDK translates requests for different providers), a translation mapping notation may be used in fenced code blocks. This uses arrow (`->`) to show the correspondence:

````
```
Unified Concept   -> Target System Handling
SYSTEM            -> Extracted to `system` parameter
USER              -> "user" role
ASSISTANT         -> "assistant" role

ContentPart Translations:
  TEXT            -> { "type": "text", "text": "..." }
  IMAGE (url)     -> { "type": "image", "source": { "type": "url", "url": "..." } }
```
````

Translation mappings are typically grouped by concern (roles, content types, tool formats) and use indentation to show sub-categories. They complement the Markdown mapping tables (Section 5.2) but are preferred when the mappings involve complex structures or inline examples that do not fit cleanly into table cells.

### 6.6 Minimal Examples

Each major concept should have at least one minimal example that demonstrates the feature in isolation. Minimal examples are placed in a dedicated subsection (e.g., "### 2.13 Minimal Examples") and are self-contained -- a reader should be able to understand the example without reading the entire spec.

### 6.7 Integration Examples

Appendices may contain longer examples that show multiple features working together. These are labeled with headers like "### A.1 Simple Text Conversation" and progress from simple to complex.

---

## 7. Definition of Done

### 7.1 Purpose

The Definition of Done (DoD) is the most critical section of an NLSpec. It transforms the spec from a description of intent into a verifiable checklist. An implementation is complete when every item in the DoD is checked off. No exceptions, no "good enough."

The DoD serves both audiences:
- **Coding agents** use it as an implementation task list and self-validation checklist.
- **Human reviewers** use it to verify that an agent's implementation is complete and correct.

### 7.2 Structure

The DoD is always the last numbered section (e.g., `## 11. Definition of Done`). It contains three types of content, in this order:

1. **Feature checklists** -- grouped by subsystem
2. **Cross-feature parity matrix** -- a table testing combinations
3. **Integration smoke test** -- an end-to-end pseudocode test

### 7.3 Feature Checklists

Feature checklists are grouped into subsections by component or concern:

```
### N.1 Component Name

- [ ] First verifiable behavior
- [ ] Second verifiable behavior
- [ ] Third verifiable behavior
```

Each item must be:

- **Observable.** It describes a behavior that can be tested, not an internal implementation detail. "Parser accepts the supported DOT subset" is observable. "Parser uses a recursive descent algorithm" is not (that is an implementation choice).
- **Atomic.** One behavior per checkbox. Do not combine multiple requirements into a single item.
- **Unambiguous.** A reader should be able to determine pass/fail without judgment calls. "Edge selection follows the 5-step priority" is unambiguous. "Edge selection works correctly" is not.

### 7.4 Cross-Feature Parity Matrix

A table where rows are test scenarios and columns are variants (providers, configurations, node types, etc.). Each cell contains `[ ]`:

```
| Test Case                                | Variant A | Variant B | Variant C |
|------------------------------------------|-----------|-----------|-----------|
| Simple scenario works                    | [ ]       | [ ]       | [ ]       |
| Complex scenario works                   | [ ]       | [ ]       | [ ]       |
| Error handling works                     | [ ]       | [ ]       | [ ]       |
```

The parity matrix ensures that features work across all supported variants, not just the most common one. It is especially important for systems with multiple backends, providers, or configurations.

### 7.5 Integration Smoke Test

A pseudocode end-to-end test that exercises the complete system. Uses `ASSERT` statements to verify expected behavior:

```
-- 1. Setup
component = create_component(config)

-- 2. Execute
result = component.execute(input)

-- 3. Verify
ASSERT result.status == "success"
ASSERT result.output contains "expected"
ASSERT artifacts_exist(output_dir, "file.json")
```

The smoke test should cover:
- The happy path (normal operation from start to finish)
- At least one error/retry path
- State persistence (checkpoints, context)
- Key integration points (human-in-the-loop, tool execution)

### 7.6 Checkbox Convention

Checkboxes use the GitHub-Flavored Markdown syntax:

```
- [ ] Unchecked item (not yet verified)
- [x] Checked item (verified)
```

In the spec source, all items start unchecked (`- [ ]`). Implementors check them off as they verify each behavior.

---

## 8. Appendices

### 8.1 When to Use Appendices

Appendices contain material that is important for completeness but would break the flow of the core sections. Content goes in an appendix when:

- It is a complete reference table consolidating information spread across multiple sections
- It is a detailed format specification (grammars, wire formats)
- It is design rationale ("Why X") that explains decisions but is not needed for implementation
- It is usage examples showing common patterns

### 8.2 Appendix Structure

Appendices are lettered and appear after the Definition of Done:

```
---

## Appendix A: Complete Attribute Reference

### Graph Attributes
(table)

### Node Attributes
(table)

---

## Appendix B: Design Decision Rationale

**Why X instead of Y?** Explanation...

**Why Z?** Explanation...
```

### 8.3 Design Decision Rationale

Design decisions are documented in a dedicated appendix (typically the last appendix) using bold questions followed by explanation paragraphs:

```
**Why provider-aligned toolsets instead of a universal tool set?** Models are
trained on specific tool formats. GPT-5.2-codex is trained on apply_patch;
forcing it to use old_string/new_string produces worse results. ...
```

Each rationale answers the implicit question "why did you make this choice?" and explains what alternatives were considered and why they were rejected.

---

## 9. Definition of Done (This Spec)

### 9.1 Document Structure

- [ ] NLSpec document has a single H1 title
- [ ] Opening paragraph states what the spec describes and that it is language-agnostic
- [ ] Horizontal rules separate the title/opening, Table of Contents, top-level sections, and appendices
- [ ] Table of Contents lists all numbered sections with anchor links
- [ ] Section 1 is "Overview and Goals" with Problem Statement and Design Principles
- [ ] Last numbered section is "Definition of Done"
- [ ] Appendices (if present) are lettered and appear either before or after the Definition of Done

### 9.2 Pseudocode

- [ ] Data structures use `RECORD`/`INTERFACE`/`ENUM`/`TOOL` keywords or bare `Name:` syntax
- [ ] Record inheritance uses `RECORD Child extends Parent:` syntax where applicable
- [ ] Functions use `FUNCTION name(params) -> ReturnType:` syntax or bare signatures for API surfaces
- [ ] Types use the documented type system (String, Integer, List<T>, Map<K,V>, T | None, etc.)
- [ ] Control flow uses UPPER_CASE keywords (IF, FOR EACH, WHILE, RETURN, YIELD, ASSERT, etc.)
- [ ] Comments use `--` prefix
- [ ] Pseudocode is language-agnostic (no language-specific syntax)

### 9.3 Requirement Language

- [ ] Requirements use plain English ("must", "should", "may") with optional uppercase for emphasis
- [ ] Bold text marks design principles, key differences, and critical warnings
- [ ] Out of scope items are documented with extension points

### 9.4 Tables and References

- [ ] Attribute tables include Key, Type, Default, and Description columns
- [ ] Cross-references use section numbers (e.g., "Section 3.4")
- [ ] Companion spec references use Markdown links with file names

### 9.5 Definition of Done

- [ ] Feature checklists use `- [ ]` checkbox syntax
- [ ] Each checklist item is observable, atomic, and unambiguous
- [ ] Cross-feature parity matrix (if applicable) covers all variants
- [ ] Integration smoke test uses ASSERT statements

### 9.6 Self-Consistency

An NLSpec document should be verifiable against this specification. Run this checklist against any NLSpec:

| Check                                              | Pass |
|----------------------------------------------------|------|
| Has H1 title and opening paragraph                 | [ ]  |
| Has Table of Contents with anchor links            | [ ]  |
| Section 1 is "Overview and Goals"                  | [ ]  |
| Has Problem Statement (1.1)                        | [ ]  |
| Has Design Principles (1.2 or 1.3)                 | [ ]  |
| Core sections use numbered H2/H3 headings          | [ ]  |
| Pseudocode uses RECORD/INTERFACE/ENUM/TOOL/FUNCTION or bare Name: | [ ]  |
| Record inheritance uses `extends` where applicable | [ ]  |
| Pseudocode uses `--` comments                      | [ ]  |
| Pseudocode types use PascalCase                    | [ ]  |
| Attribute tables have Key/Type/Default/Description | [ ]  |
| Last numbered section is "Definition of Done"      | [ ]  |
| Appendices (if present) are lettered               | [ ]  |
| DoD has feature checklists with `- [ ]` items      | [ ]  |
| DoD has cross-feature parity matrix or smoke test  | [ ]  |
| Horizontal rules separate major sections           | [ ]  |

### 9.7 Integration Smoke Test

Validate the NLSpec format by parsing this very document (`nlspec.md`) and a deliberately malformed document:

```
-- 1. Parse this spec (self-referential validation)
doc = parse_nlspec("nlspec.md")
ASSERT doc is not NONE

-- 2. Structural checks against concrete values
ASSERT doc.h1_title == "NLSpec: Natural Language Specification Format"
ASSERT doc.sections[0].heading == "## 1. Overview and Goals"
ASSERT doc.sections[0].subsections[0].heading == "### 1.1 Problem Statement"
ASSERT doc.sections[-1].heading STARTS_WITH "## 9. Definition of Done"
ASSERT doc.table_of_contents_entries == 9

-- 3. Pseudocode block verification (spot-check Section 3)
pseudocode_section = doc.section("3. Pseudocode Language")
code_blocks = pseudocode_section.fenced_code_blocks
ASSERT LENGTH(code_blocks) > 0
-- Verify RECORD keyword appears with PascalCase type name
ASSERT ANY(code_blocks, b -> b.text CONTAINS "RECORD Name:")
-- Verify comments use -- prefix, not // or #
ASSERT ANY(code_blocks, b -> b.text CONTAINS "-- description")
ASSERT NONE(code_blocks, b -> b.text CONTAINS "// description")

-- 4. Attribute table format (spot-check Section 3.4)
type_table = doc.section("3. Pseudocode Language").tables[0]
ASSERT type_table.columns[0] == "Type"
ASSERT type_table.columns[1] == "Meaning"
ASSERT ANY(type_table.rows, r -> r["Type"] == "`String`")

-- 5. Definition of Done completeness
dod = doc.section("9. Definition of Done")
checkboxes = dod.find_all("- [ ]")
ASSERT LENGTH(checkboxes) >= 10
parity_table = dod.tables[0]
ASSERT parity_table.columns CONTAINS "Pass"
smoke_test = dod.subsection("9.7 Integration Smoke Test")
ASSERT smoke_test.fenced_code_blocks[0].text CONTAINS "ASSERT"

-- 6. Appendices are lettered and separated
ASSERT doc.appendices[0].heading == "## Appendix A: NLSpec Anatomy Cheat Sheet"
ASSERT doc.appendices[1].heading == "## Appendix B: Design Decision Rationale"
ASSERT doc.horizontal_rule_before(doc.appendices[0])

-- 7. Error case: malformed document is rejected
bad_doc = "# Missing Everything\nNo table of contents, no sections, no DoD."
errors = validate_nlspec(bad_doc)
ASSERT LENGTH(errors) > 0
ASSERT ANY(errors, e -> e CONTAINS "Table of Contents")
ASSERT ANY(errors, e -> e CONTAINS "Overview and Goals")
ASSERT ANY(errors, e -> e CONTAINS "Definition of Done")
```

---

## Appendix A: NLSpec Anatomy Cheat Sheet

```
# Title
(One-sentence description. Optionally: language-agnostic, implementable from scratch.)
---
## Table of Contents
1. [Overview and Goals](#1-overview-and-goals)
2. [Core Topic A](#2-core-topic-a)
3. [Core Topic B](#3-core-topic-b)
4. [Definition of Done](#4-definition-of-done)
---
## 1. Overview and Goals
### 1.1 Problem Statement
### 1.2 Design Principles
### 1.3 Architecture (optional)
---
## 2. Core Topic A
### 2.1 Concept
### 2.2 Data Model
### 2.3 Algorithm
### 2.4 Examples
---
## 3. Core Topic B
### 3.1 ...
---
## 4. Definition of Done
### 4.1 Feature Group A
- [ ] Observable behavior 1
- [ ] Observable behavior 2
### 4.2 Feature Group B
- [ ] Observable behavior 3
### 4.3 Parity Matrix
| Test Case | Variant A | Variant B |
|-----------|-----------|-----------|
| Scenario  | [ ]       | [ ]       |
### 4.4 Integration Smoke Test
```pseudocode
ASSERT result.status == "success"
```
---
## Appendix A: Complete Reference
## Appendix B: Design Decision Rationale

(Alternative: Appendices may appear before the Definition of Done)
```

---

## Appendix B: Design Decision Rationale

**Why Markdown instead of a custom format?** Markdown is universally supported. Every coding agent can read it. Every developer has a renderer. Every version control system can diff it. A custom format would require tooling before anyone could use it. Markdown requires nothing.

**Why pseudocode instead of a real programming language?** Pseudocode prevents language bias. A spec written in Python subtly encourages Python-style implementations. A spec written in Go encourages Go-style implementations. Pseudocode lets the implementor use the right idioms for their target language. It also prevents the reader from confusing "this is how it works" (the spec) with "this is how it should be coded" (an implementation detail).

**Why `--` for comments instead of `//` or `#`?** `//` implies C/Java/Go/JavaScript. `#` implies Python/Ruby/Shell. `--` is used in SQL, Haskell, Lua, and Ada but is not strongly associated with any mainstream language. This reinforces the language-neutral intent of the pseudocode.

**Why require a Definition of Done instead of just the spec body?** A spec body describes what to build. A Definition of Done describes how to verify that you built it. Without the DoD, "is it done?" is a subjective judgment. With the DoD, it is a checklist. This is especially important for coding agents, which need explicit success criteria to know when to stop.

**Why checkboxes instead of test code?** Test code implies a specific testing framework and language. Checkboxes are universal. An implementor translates each checkbox into tests appropriate for their language and framework. The checkbox captures the requirement; the test captures the verification.

**Why include design rationale?** Specs without rationale invite bikeshedding. When a developer (or agent) encounters a constraint they find surprising, rationale explains why it exists. This prevents well-meaning changes that violate design invariants. It also helps implementors make informed tradeoffs when their context demands adaptation.

**Why one spec per file?** Self-containment is a feature, not a limitation. A single file can be handed to a coding agent with a single instruction: "Implement this." Multiple files require the agent to understand file relationships, loading order, and cross-file dependencies. One file eliminates this coordination cost. Cross-references to companion specs are explicit links, not implicit dependencies.

**Why structured prose instead of pure formalism?** Pure formal specs (BNF, Protocol Buffers, OpenAPI) define structure without conveying intent, context, or rationale. They are precise but opaque. NLSpecs use formal elements (BNF grammars, typed pseudocode, attribute tables) where precision matters, and natural language everywhere else. The result is a document that a coding agent can implement from and a human can understand.
