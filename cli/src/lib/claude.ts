export interface Suggestion {
  title: string;
  year?: string;
  type?: string;
  reason: string;
}

export async function suggest(ratingsCtx: string, prefsCtx: string, excludeCtx: string, userPrompt?: string): Promise<Suggestion[]> {
  const parts = [
    ratingsCtx && `My ratings:\n${ratingsCtx}`,
    prefsCtx && `My preferences:\n${prefsCtx}`,
    excludeCtx && `Already seen or on my watchlist (DO NOT suggest these):\n${excludeCtx}`,
    userPrompt && `Mood/constraint: ${userPrompt}`,
    "Suggest 20 titles I'd enjoy.",
    "Reply with ONLY a raw JSON array, no markdown fences, no explanation.",
    'Format: [{"title":"...","year":"...","type":"movie|series","reason":"..."},...]',
  ].filter(Boolean);

  const proc = Bun.spawn(
    ["claude", "-p", parts.join("\n\n"), "--output-format", "json"],
    { stdout: "pipe", stderr: "pipe" },
  );

  const out = await new Response(proc.stdout).text();
  await proc.exited;

  // --output-format json returns {result: "..."} where result is the text
  let text = out.trim();
  try {
    const wrapper = JSON.parse(text);
    text = typeof wrapper === "string" ? wrapper : wrapper.result ?? text;
  } catch {
    // not wrapped, use raw
  }

  // strip markdown fences if Claude ignores instructions
  text = text.replace(/^```(?:json)?\s*\n?/m, "").replace(/\n?```\s*$/m, "").trim();

  // find the JSON array in the text
  const start = text.indexOf("[");
  const end = text.lastIndexOf("]");
  if (start === -1 || end === -1) {
    throw new Error("Claude did not return a JSON array");
  }

  return JSON.parse(text.slice(start, end + 1));
}
