$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = "::: "

$env.MASCOPE_PATH = "/home/ixxie/repos/mascope"

$env.HANDLER = "codeium"
$env.TERMINAL = "ghostty"

$env.QT_QPA_PLATFORM = "wayland"

$env.DOTFILES = "/home/ixxie/repos/dotfiles"

cat $"($env.DOTFILES)/secrets/anthropic_key.txt" | $env.ANTHROPIC_API_KEY = $in
cat $"($env.DOTFILES)/secrets/github_token.txt" | $env.CR_PAT = $in
