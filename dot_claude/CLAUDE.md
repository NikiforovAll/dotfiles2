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

<duplicate_plan>
IMPORTANT: Before starting implementation of the approved plan - ask user if he wants to store it. Use `AskUserQuestion` to ask user.
If Yes, copy a PLAN to `_plans/<plan_name>` (from `~/.claude/plans`) folder in the root of the repository. 
Put a footer in the copied plan file with the line: `# This file is a copy of original plan ~/.claude/plans/<plan_name>`.
Copying existing plan should be the first step in implementation of the plan as `TodoWrite` item.
</duplicate_plan>

<user_mnemonics>
Here is an example of user mnemonics, when user specifies:

>bg means - "Run task in the background"
>pl means - "Run in parallel"
>td means - "Add task to TODO list using `TodoWrite`
>aq means - "Ask user a question using `AskUserQuestion`"
>skl means - "Find matching skill and use it"
</user_mnemonics>

<commit_messages>
Do not mention Claude Code in commit messages. As if it was written by a human developer.
</commit_messages>

<windows_path_issues>
If you experience issues with Update/Write tool, try to use relative file path
</windows_path_issues>

<dotnet_build_rules>
- ALWAYS build via: `dotnet build -p:WarningLevel=0 /clp:ErrorsOnly`
</dotnet_build_rules>