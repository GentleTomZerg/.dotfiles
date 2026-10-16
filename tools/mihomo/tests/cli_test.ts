import { assertEquals } from "@std/assert";
import { runCli } from "../src/cli.ts";
import { FakeCommandRunner } from "./fake_command.ts";
import { recordingReporter } from "./fake_report.ts";

/** Worst-case fast: a single attempt with no delay between them. */
const env = {
  HOME: "/home/example",
  MIHOMO_RETRY_TRIES: "1",
  MIHOMO_RETRY_DELAY: "0",
};

Deno.test("runCli dispatches status and exits 0 when every check passes", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner((command) =>
    command === "uname"
      ? { code: 0, stdout: "Linux\n", stderr: "" }
      : { code: 0, stdout: "", stderr: "" }
  );

  const code = await runCli(["status"], { env, runner, report });

  assertEquals(code, 0);
  assertEquals(out.at(-1), "status: all checks passed");
  assertEquals(err, []);
});

Deno.test("runCli dispatches status and exits 1 when a check fails", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 1, stdout: "", stderr: "" }));

  const code = await runCli(["status"], { env, runner, report });

  assertEquals(code, 1);
  assertEquals(out, []);
  assertEquals(err, ["status: FAIL - mihomo is not running"]);
});

Deno.test("runCli dispatches start and refuses a duplicate instance", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 0, stdout: "4242\n", stderr: "" }));

  const code = await runCli(["start"], { env, runner, report });

  assertEquals(code, 1);
  assertEquals(out, ["mihomo has already started."]);
  assertEquals(err, []);
});

Deno.test("runCli dispatches stop and exits 1 when mihomo is not running", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 1, stdout: "", stderr: "" }));

  const code = await runCli(["stop"], { env, runner, report });

  assertEquals(code, 1);
  assertEquals(out, ["mihomo is not running"]);
  assertEquals(err, []);
});

Deno.test("runCli prints usage naming the subcommands for an unknown subcommand", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 0, stdout: "", stderr: "" }));

  const code = await runCli(["bogus"], { env, runner, report });

  assertEquals(code, 1);
  assertEquals(out, []);
  assertEquals(err, [
    "Error: unknown subcommand 'bogus'.",
    "Usage: mihomo <render|start|stop|status>",
  ]);
  assertEquals(runner.calls.length, 0);
});

Deno.test("runCli prints usage when no subcommand is given", async () => {
  const { report, out, err } = recordingReporter();
  const runner = new FakeCommandRunner(() => ({ code: 0, stdout: "", stderr: "" }));

  const code = await runCli([], { env, runner, report });

  assertEquals(code, 1);
  assertEquals(out, []);
  assertEquals(err, ["Error: no subcommand given.", "Usage: mihomo <render|start|stop|status>"]);
  assertEquals(runner.calls.length, 0);
});
