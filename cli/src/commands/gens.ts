import type { Command } from "commander";
import { genDash } from "./gen.ts";

export default function register(program: Command) {
  program
    .command("gens")
    .description("Interactive NixOS generation & build dashboard")
    .action(genDash);
}
