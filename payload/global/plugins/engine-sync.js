import { execFile } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

export const EngineSyncPlugin = async ({ client }) => {
  const HOME = process.env.HOME || "";
  const ENGINE = `${HOME}/.cairnlore`;
  const STAMP = `${HOME}/.config/cairnlore/engine-head`;
  const BRANCH = process.env.CAIRNLORE_BRANCH || "main";

  function git(args, timeoutMs) {
    return new Promise((resolve) => {
      execFile("git", ["-C", ENGINE, ...args], { timeout: timeoutMs || 20000 }, (err, stdout) => {
        resolve(err ? "" : String(stdout || "").trim());
      });
    });
  }
  function writeStamp(sha) {
    try {
      mkdirSync(dirname(STAMP), { recursive: true });
      writeFileSync(STAMP, `${sha}\n`);
    } catch { /* the stamp is advisory only */ }
  }
  async function log(message) {
    try {
      await client.app.log({ body: { service: "engine-sync", level: "info", message } });
    } catch { /* logging must never break a session */ }
  }
  function notify(message) {
    execFile("osascript", ["-e", `display notification "${message}" with title "cairnlore engine"`], () => {});
  }

  return {
    event: async ({ event }) => {
      try {
        if (!event || (event.type !== "session.created" && event.type !== "session.idle")) return;
        if (event.type === "session.created") {
          await git(["pull", "--ff-only", "-q"]);
          const head = await git(["rev-parse", "HEAD"]);
          if (head) writeStamp(head);
          return;
        }
        const before = await git(["rev-parse", "HEAD"]);
        if (!before) return;
        await git(["fetch", "-q", "origin"], 30000);
        const remote = await git(["rev-parse", `origin/${BRANCH}`]);
        if (!remote || remote === before) return;
        await git(["pull", "--ff-only", "-q"]);
        const after = await git(["rev-parse", "HEAD"]);
        if (!after || after === before) return;
        writeStamp(after);
        await log(`engine moved ${before.slice(0, 7)} -> ${after.slice(0, 7)}; open sessions reload via R27`);
        notify(`engine updated ${after.slice(0, 7)}; sessions reload on next turn`);
      } catch { /* sync must never break a session */ }
    },
  };
};
