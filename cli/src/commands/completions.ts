import type { Command } from "commander";
import { findRepos } from "./repos.ts";
import { findApps } from "./open.ts";

export default function register(program: Command) {
  program
    .command("completions")
    .description("Generate fish completions")
    .argument("[command]", "Command to complete")
    .argument("[current]", "Current word being typed")
    .action(async (command?: string, current?: string) => {
      if (command === "cd") {
        const repos = await findRepos();
        const matches = repos.filter((r) => {
          const name = r.name.includes("/") ? r.name.split("/")[1] : r.name;
          return !current || name.startsWith(current);
        });
        for (const r of matches) {
          const name = r.name.includes("/") ? r.name.split("/")[1] : r.name;
          console.log(name);
        }
      } else if (command === "sys") {
        const sysCmds = ["switch", "update", "gc"];
        for (const cmd of sysCmds) {
          if (!current || cmd.startsWith(current)) {
            console.log(cmd);
          }
        }
      } else if (command === "open") {
        const apps = await findApps();
        for (const app of apps) {
          if (!current || app.id.toLowerCase().startsWith(current.toLowerCase())) {
            console.log(app.id);
          }
        }
      } else if (command === "snip") {
        const snipCmds = ["region", "screen", "rec"];
        for (const cmd of snipCmds) {
          if (!current || cmd.startsWith(current)) {
            console.log(cmd);
          }
        }
      } else {
        const commands = ["sys", "repos", "cd", "tree", "open", "snip", "completions"];
        for (const cmd of commands) {
          if (!current || cmd.startsWith(current)) {
            console.log(cmd);
          }
        }
      }
    });
}
