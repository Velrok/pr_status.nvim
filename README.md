# pr_status.nvim

Neovim plugin written in lua which uses the `gh` cli to fetch pull request check results and allow to display them in a status bar or similar.

## ⚡️ Requirements

- Neovim >= 0.8.0
- a [Nerd Font](https://www.nerdfonts.com/)
- local install of [github cli](https://github.com/cli/cli)
- this can in theory be configured to be something else, but that would also require a line by line parser for its output

## 📦 Installation

Install the plugin with your preferred package manager:

```lua
-- lazy.nvim
```

## ⚙️ Configuration

**pr_status.nvim** comes with the following defaults:

```lua
{
  icons = {
    gh_icon = " ",
    unknown = '?',
    running = ' ',
    failed = ' ',
    passed = ' ',
  },
  failure_decorations = {
    left = '[',
    right = ']',
    join_string = ', ',
    separator = ' ',
  },
  gh_command = "gh pr status",
  status_line_parser = github_cli_parser,
  auto_start = false, -- or function which returns true|false
  timer = {
    initial_delay_ms = 1000,
    regular_poll_delay_ms = 30000,
  }
}
```
