import type { Command } from "commander";
import { run } from "../utils.ts";

export default function register(program: Command) {
  program
    .command("tree")
    .description("Tree with gitignore and dirs first")
    .allowUnknownOption()
    .allowExcessArguments()
    .action(async (_, cmd) => {
      const extra = cmd.args.length ? cmd.args : ["."];
      const args = [
        "eza", "--tree", "--icons",
        "--git-ignore", "--group-directories-first",
        ...extra,
      ];
      await run(args);
    });
}
