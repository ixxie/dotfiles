import { readFileSync, existsSync } from "fs";

const CONFIG_PATH = `${process.env.HOME}/.config/yo/config.json`;

export interface Config {
  cleanupRatio?: number;
  proxy?: string;
}

let _config: Config | null = null;

export function config(): Config {
  if (_config) return _config;
  try {
    if (existsSync(CONFIG_PATH)) {
      _config = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
    } else {
      _config = {};
    }
  } catch {
    _config = {};
  }
  return _config!;
}
