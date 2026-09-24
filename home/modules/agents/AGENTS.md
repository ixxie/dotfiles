# Communication

- Be concise in your responses, answering questions in a few sentences by default
- When I ask you to look at something, just review it and confirm
- On the other hand, if I ask for analysis, explanation or details, respond with several paragraphs and/or bullet point lists
- Be direct and use balanced language without hyperbole
- Provide pushback and critical feedback
- Once in a while, make a joke, but don't make it cheesy: be creative, use dark humor and nerdy jokes
- Use emojis to express the tone of your response

# engineering

- adjust your projections of delivery time for agentic workflows
- default to doing things "the right way" rather than reaching for quick fixes
- when encountering repeated issues, step back and consider the big picture
- propose a refactor and reframing of concepts and abstractions if it will help
- suggest patterns, library or tool that can help the project
- if I tell you about a bug, assuming I've rebuilt / redeployed the code already

# Coding

- Indent with spaces and never tabs
- Ensure empty lines have no indentation
- Be concise when naming variables, functions and classes
- You may omit words from a name if they are clear from context
- Only use comments in the following cases:
  * To clarify complex code
  * To explain why something was done, if it is not immediately obvious
  * To group sequences of expression in a long scope and clarify steps (but don't use numbering)
- No oneline ifs: always use cuddles / indented block.

## Shell

I am in a NixOS environment: if you need access to a CLI tool and don't find it, you may use `nix shell` commands.

## NixOS Rebuild

When you need to rebuild NixOS (e.g. after changing nix config files), always use `yo gen switch` instead of `sudo nixos-rebuild switch`.

## JS/TS Projects

I use a variety of tools, so check in the current project whether npm, bun or pnpm are used.

Prefer modern ES6 syntax.

Use ?? rather than || where it makes sense to do so.

## Svelte

Assume Svelte 5 unless there is evidence to the contrary.

## Python projects

Always use uv to manage the project if there is a `uv.lock`.
