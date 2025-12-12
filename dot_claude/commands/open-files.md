---
allowed-tools: Bash(code:*)
argument-hint: --no-ask
description: Open files in VS Code from the command line using the `code` command.
---

Suggest to open most recent/latest files in VS Code.

Also, use $ARGUMENTS for instructions on which files to open.


Example of command:

`code -r <file1> <file2> ... <fileN>`

IF NOT '--no-ask' in $ARGUMENTS
THEN
Use multi-choice `AskUserQuestion` to let user select files to open.
