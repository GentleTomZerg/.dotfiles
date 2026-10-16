export interface Settings {
  configDir: string;
  templatePath: string;
  providersPath: string;
  runtimePath: string;
  tweaksPath: string;
  serviceUrl: string;
  controllerUrl: string;
  dnsVirtualIp: string;
  networkService: string;
  retryTries: number;
  retryDelay: number;
}

/**
 * Derive every path and constant from the environment map. `configDir` comes
 * from `MIHOMO_CONFIG_PATH` or the home directory only — never from the
 * script's own location, which changes with how it was invoked.
 */
export function loadSettings(env: Record<string, string | undefined>): Settings {
  const configDir = env.MIHOMO_CONFIG_PATH || `${env.HOME ?? ""}/.config/mihomo`;
  return {
    configDir,
    templatePath: `${configDir}/mihomo.yaml`,
    providersPath: `${configDir}/providers.yaml`,
    runtimePath: `${configDir}/mihomo_runtime.yaml`,
    tweaksPath: `${configDir}/provider-tweaks.yaml`,
    serviceUrl: env.MIHOMO_SERVICE_URL || "http://127.0.0.1:7890",
    controllerUrl: env.MIHOMO_CONTROLLER_URL || "http://127.0.0.1:9090",
    dnsVirtualIp: "198.18.0.2",
    networkService: env.NETWORK_SERVICE || "Wi-Fi",
    retryTries: parseIntEnv(env.MIHOMO_RETRY_TRIES, 10),
    retryDelay: parseIntEnv(env.MIHOMO_RETRY_DELAY, 1),
  };
}

function parseIntEnv(raw: string | undefined, fallback: number): number {
  if (raw === undefined || raw === "") return fallback;
  const value = Number(raw);
  return Number.isFinite(value) ? value : fallback;
}
