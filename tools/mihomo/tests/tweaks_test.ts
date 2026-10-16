import { assertEquals } from "@std/assert";
import { liftProvider, type LoadedProvider, locateProviders, selectTweaks } from "../src/tweaks.ts";

Deno.test("liftProvider renames dns.nameserver to dns.proxy-server-nameserver", () => {
  const doc = { dns: { nameserver: ["https://zone.example.test/api-query"] } };
  assertEquals(liftProvider(doc), {
    overlay: { dns: { "proxy-server-nameserver": ["https://zone.example.test/api-query"] } },
    skipped: [],
  });
});

Deno.test("liftProvider passes through use-hosts, fake-ip-filter, root hosts and a shipped proxy-server-nameserver", () => {
  const doc = {
    dns: {
      "use-hosts": true,
      "fake-ip-filter": ["+.stun.example.test", "ntp.example.test"],
      "proxy-server-nameserver": ["https://psn.example.test/api-query"],
    },
    hosts: { "+.example.test": "128.108.220.144" },
  };
  assertEquals(liftProvider(doc), {
    overlay: {
      dns: {
        "proxy-server-nameserver": ["https://psn.example.test/api-query"],
        "use-hosts": true,
        "fake-ip-filter": ["+.stun.example.test", "ntp.example.test"],
      },
      hosts: { "+.example.test": "128.108.220.144" },
    },
    skipped: [],
  });
});

Deno.test("liftProvider never lifts the template-owned keys", () => {
  const doc = {
    dns: {
      enable: true,
      listen: "0.0.0.0:1053",
      "enhanced-mode": "fake-ip",
      "fake-ip-range": "198.18.0.1/16",
      "default-nameserver": ["119.29.29.29", "223.5.5.5"],
      nameserver: ["https://zone.example.test/api-query"],
    },
  };
  assertEquals(liftProvider(doc), {
    overlay: { dns: { "proxy-server-nameserver": ["https://zone.example.test/api-query"] } },
    skipped: [],
  });
});

Deno.test("liftProvider skips circular resolvers but keeps #key=value parameters", () => {
  const doc = {
    dns: {
      nameserver: [
        "https://zone.example.test/api-query",
        "1.1.1.1#RULES",
        "2.2.2.2#proxy",
        "3.3.3.3#ecs=1.2.3.4/24&skip-cert-verify=true",
      ],
    },
  };
  assertEquals(liftProvider(doc), {
    overlay: {
      dns: {
        "proxy-server-nameserver": [
          "https://zone.example.test/api-query",
          "3.3.3.3#ecs=1.2.3.4/24&skip-cert-verify=true",
        ],
      },
    },
    skipped: ["1.1.1.1#RULES", "2.2.2.2#proxy"],
  });
});

Deno.test("liftProvider returns an inert overlay when nothing can be lifted", () => {
  assertEquals(liftProvider({}), { overlay: {}, skipped: [] });
  assertEquals(liftProvider({ dns: { enable: true, listen: "0.0.0.0:1053" } }), {
    overlay: {},
    skipped: [],
  });
  assertEquals(liftProvider({ dns: { nameserver: ["1.1.1.1#RULES"] } }), {
    overlay: {},
    skipped: ["1.1.1.1#RULES"],
  });
});

Deno.test("liftProvider drops empty arrays so they cannot replace a template key", () => {
  assertEquals(liftProvider({ dns: { "fake-ip-filter": [] } }), { overlay: {}, skipped: [] });
  assertEquals(liftProvider({ dns: { nameserver: [] }, hosts: [] }), { overlay: {}, skipped: [] });
});

Deno.test("liftProvider keeps unique resolvers in provider order", () => {
  const doc = {
    dns: {
      "proxy-server-nameserver": ["https://a.test/q", "https://b.test/q"],
      nameserver: ["https://b.test/q", "https://a.test/q"],
    },
  };
  assertEquals(liftProvider(doc).overlay, {
    dns: { "proxy-server-nameserver": ["https://a.test/q", "https://b.test/q"] },
  });
});

Deno.test("locateProviders resolves cache paths against the config dir and reports pathless providers", () => {
  const providersConfig = {
    "proxy-providers": {
      eix: { type: "http", path: "./proxy_providers/e-ix.yaml" },
      abs: { type: "http", path: "/var/cache/other.yaml" },
      nopath: { type: "http" },
    },
  };
  assertEquals(locateProviders(providersConfig, "/home/u/.config/mihomo"), {
    refs: [
      { name: "eix", path: "/home/u/.config/mihomo/proxy_providers/e-ix.yaml" },
      { name: "abs", path: "/var/cache/other.yaml" },
    ],
    noPath: ["nopath"],
  });
});

function provider(name: string, path: string, doc: unknown): LoadedProvider {
  return { name, path, doc };
}

Deno.test("selectTweaks is missing when no provider lifts a resolver", () => {
  assertEquals(
    selectTweaks([provider("eix", "/p/eix.yaml", { proxies: [] })]),
    {
      overlay: {},
      skipped: [],
      state: "missing",
      applied: [],
      sourceName: null,
      sourcePath: null,
      ignoredNames: [],
    },
  );
});

Deno.test("selectTweaks is found for a single contributing provider", () => {
  const selection = selectTweaks([
    provider("eix", "/p/eix.yaml", {
      dns: { nameserver: ["https://zone.example.test/api-query"] },
    }),
  ]);
  assertEquals(selection.state, "found");
  assertEquals(selection.sourceName, "eix");
  assertEquals(selection.sourcePath, "/p/eix.yaml");
  assertEquals(selection.applied, ["https://zone.example.test/api-query"]);
  assertEquals(selection.ignoredNames, []);
  assertEquals(selection.overlay, {
    dns: { "proxy-server-nameserver": ["https://zone.example.test/api-query"] },
  });
});

Deno.test("selectTweaks is multi when several providers contribute, naming the ignored caches", () => {
  const selection = selectTweaks([
    provider("a", "/p/a.yaml", { dns: { nameserver: ["https://a.example.test/q"] } }),
    provider("b", "/p/b.yaml", { dns: { nameserver: ["https://b.example.test/q"] } }),
  ]);
  assertEquals(selection.state, "multi");
  assertEquals(selection.sourceName, "a");
  assertEquals(selection.applied, ["https://a.example.test/q"]);
  assertEquals(selection.ignoredNames, ["b"]);
});

Deno.test("selectTweaks names a dns-carrying provider that lifts no resolver among the ignored", () => {
  const selection = selectTweaks([
    provider("a", "/p/a.yaml", { dns: { nameserver: ["https://a.example.test/q"] } }),
    provider("b", "/p/b.yaml", { dns: { "use-hosts": true } }),
  ]);
  assertEquals(selection.state, "found");
  assertEquals(selection.sourceName, "a");
  assertEquals(selection.ignoredNames, ["b"]);
});
