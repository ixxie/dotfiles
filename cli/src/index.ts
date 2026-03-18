#!/usr/bin/env bun
import { program } from "commander";
import pc from "picocolors";

import gen from "./commands/gen.ts";
import snip from "./commands/snip.ts";
import repos from "./commands/repos.ts";
import tree from "./commands/tree.ts";
import open from "./commands/open.ts";
import completions from "./commands/completions.ts";
import media from "./commands/media.ts";
import clip from "./commands/clip.ts";
import gens from "./commands/gens.ts";
import discord from "./commands/discord.ts";

program
  .name("org")
  .description(pc.bold("System management CLI"))
  .version("0.1.0");

gen(program);
snip(program);
repos(program);
tree(program);
open(program);
completions(program);
media(program);
clip(program);
gens(program);
discord(program);

program.parse();
