<use_agents_memory>
Read the @AGENTS.md if present to understand the overall instructions for the agent.
</use_agents_memory>

<use_rg>
You run in an environment where `rg` is available; whenever a search requires fast text searching, use `rg <pattern>` (or set additional flags as appropriate). USE it over `grep`.
</use_rg>

<use_ast_grep>
You run in an environment where `ast-grep` is available; whenever a search requires syntax-aware or structural matching, consider using `ast-grep --lang csharp -p '<pattern>'` (or set `--lang` appropriately).
</use_ast_grep>

<use_fd>
You run in an environment where `fd` is available; whenever a search requires fast file searching, use `fd <pattern>` (or set additional flags as appropriate).
</use_fd>

<comments>
DO NOT add unnecessary comments, comment should explain WHY not WHAT. IMPORTANT: Add comments only when necessary.
IMPORTANT: DO NOT remove existing comments.
</comments>

# Additional Instructions
Use @CLAUDE.local.md for additional instructions.