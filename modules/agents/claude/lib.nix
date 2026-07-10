{lib}: let
  baseSettings = {
    hasCompletedOnboarding = true;
    theme = "dark";
    preferredNotifChannel = "ghostty";
    voiceEnabled = true;
    preferredReasoningEffort = "max";
    permissions.defaultMode = "auto";
    skipAutoPermissionPrompt = true;
  };

  agentsMd = builtins.readFile ../AGENTS.md;
  skillsDir = ../skills;

  allSkills =
    lib.mapAttrs'
    (n: _:
      lib.nameValuePair
      (lib.removeSuffix ".md" n)
      (builtins.readFile (skillsDir + "/${n}")))
    (lib.filterAttrs
      (n: t: t == "regular" && lib.hasSuffix ".md" n)
      (builtins.readDir skillsDir));

  # base16 palette -> Claude color override keys.
  # Only keys present in the base ("dark"/"light"/...) palette are accepted by Claude;
  # everything else is silently ignored. Kept focused on high-signal UI elements.
  mkPalette = s: {
    text = "#${s.base05}";
    inverseText = "#${s.base00}";
    subtle = "#${s.base02}";
    inactive = "#${s.base03}";
    inactiveShimmer = "#${s.base04}";

    promptBorder = "#${s.base02}";
    promptBorderShimmer = "#${s.base04}";
    bashBorder = "#${s.base08}";

    claude = "#${s.base09}";
    claudeShimmer = "#${s.base09}";
    claudeBlue_FOR_SYSTEM_SPINNER = "#${s.base0D}";
    claudeBlueShimmer_FOR_SYSTEM_SPINNER = "#${s.base0D}";
    permission = "#${s.base0E}";
    permissionShimmer = "#${s.base0E}";
    suggestion = "#${s.base0E}";
    remember = "#${s.base0E}";
    autoAccept = "#${s.base0E}";
    merged = "#${s.base0E}";
    planMode = "#${s.base0C}";
    ide = "#${s.base0D}";
    fastMode = "#${s.base09}";
    fastModeShimmer = "#${s.base09}";

    success = "#${s.base0B}";
    error = "#${s.base08}";
    warning = "#${s.base0A}";
    warningShimmer = "#${s.base0A}";

    userMessageBackground = "#${s.base01}";
    userMessageBackgroundHover = "#${s.base02}";
    selectionBg = "#${s.base02}";
    bashMessageBackgroundColor = "#${s.base01}";
    memoryBackgroundColor = "#${s.base01}";

    rate_limit_fill = "#${s.base0E}";
    rate_limit_empty = "#${s.base02}";
  };
in {
  inherit baseSettings agentsMd allSkills mkPalette;

  mkProfile = {
    dir,
    settings ? {},
    skills ? null,
    themes ? {},
  }: let
    mergedSettings = lib.recursiveUpdate baseSettings settings;
    settingsFile = builtins.toFile "claude-settings.json" (builtins.toJSON mergedSettings);
    activationKey = "claudeSettings_" + lib.replaceStrings ["." "/" "-"] ["_" "_" "_"] dir;
    skillNames =
      if skills == null
      then builtins.attrNames allSkills
      else skills;
    skillFiles =
      lib.listToAttrs (map (s: {
          name = "${dir}/skills/${s}/SKILL.md";
          value = {text = allSkills.${s};};
        })
        skillNames);
    themeFiles =
      lib.mapAttrs'
      (slug: theme:
        lib.nameValuePair
        "${dir}/themes/${slug}.json"
        {text = builtins.toJSON theme;})
      themes;
  in {
    home.file =
      {
        "${dir}/CLAUDE.md" = {text = agentsMd;};
      }
      // skillFiles
      // themeFiles;

    # settings.json must stay writable: Claude Code mutates it at runtime
    # (/voice, /theme, onboarding). A read-only store symlink makes those
    # writes fail, so seed a real copy on activation instead of linking it.
    # Declared values still win on each rebuild.
    # DAG entry built literally (equivalent to hm.dag.entryAfter) since the
    # home-manager lib isn't in scope at this NixOS-module call site.
    home.activation.${activationKey} = {
      after = ["writeBoundary"];
      before = [];
      data = ''
        run rm -f "$HOME/${dir}/settings.json"
        run install -Dm644 ${settingsFile} "$HOME/${dir}/settings.json"
      '';
    };
  };
}
