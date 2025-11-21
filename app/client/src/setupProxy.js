let createProxyMiddleware;

try {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  createProxyMiddleware =
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    require("http-proxy-middleware").createProxyMiddleware;
} catch (e) {
  // eslint-disable-next-line no-console
  console.warn(
    "[setupProxy] http-proxy-middleware não encontrado. Usando configuração do package.json.",
  );
}

const backendUrl = process.env.REACT_APP_BACKEND_URL || "http://localhost:8080";

module.exports = function (app) {
  if (createProxyMiddleware) {
    // Configuração avançada com http-proxy-middleware
    const apiProxy = createProxyMiddleware({
      target: backendUrl,
      changeOrigin: true,
      secure: false,
      headers: {
        Connection: "keep-alive",
      },
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      onProxyReq: (proxyReq, req) => {
        proxyReq.setHeader("Host", new URL(backendUrl).host);
        // eslint-disable-next-line @appsmith/object-keys
        Object.keys(req.headers).forEach((headerName) => {
          const headerValue = req.headers[headerName];

          const headersToSkip = [
            "host", // Já configurado acima
            "connection",
            "upgrade",
            "sec-websocket-key",
            "sec-websocket-version",
            "sec-websocket-extensions",
            "sec-websocket-protocol",
          ];

          if (
            !headersToSkip.includes(headerName.toLowerCase()) &&
            headerValue
          ) {
            // Preservar o case original do header (importante para X-Appsmith-Version)
            proxyReq.setHeader(headerName, headerValue);
          }
        });

        const appsmithVersion = proxyReq.getHeader("X-Appsmith-Version");

        if (!appsmithVersion || appsmithVersion === "UNKNOWN") {
          if (!proxyReq.getHeader("X-Requested-By")) {
            proxyReq.setHeader("X-Requested-By", "Appsmith");
          }
        }

        const contentType =
          req.headers["content-type"] || req.headers["Content-Type"];

        if (contentType) {
          proxyReq.setHeader("Content-Type", contentType);
        }
      },
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      onProxyRes: (proxyRes, req) => {
        // Permitir CORS
        const origin = req.headers.origin || "*";

        proxyRes.headers["Access-Control-Allow-Origin"] = origin;
        proxyRes.headers["Access-Control-Allow-Credentials"] = "true";
        proxyRes.headers["Access-Control-Allow-Methods"] =
          "GET, POST, PUT, DELETE, PATCH, OPTIONS";
        proxyRes.headers["Access-Control-Allow-Headers"] =
          "Content-Type, Authorization, X-CSRF-Token, X-XSRF-Token, X-Requested-With, X-Appsmith-Version, X-Requested-By";

        const setCookieHeader = proxyRes.headers["set-cookie"];

        if (setCookieHeader) {
          // Garantir que seja um array
          const cookies = Array.isArray(setCookieHeader)
            ? setCookieHeader
            : [setCookieHeader];

          proxyRes.headers["set-cookie"] = cookies.map((cookie) => {
            if (!cookie) return cookie;

            let adjustedCookie = cookie.replace(/Domain=[^;]+/i, "");

            adjustedCookie = adjustedCookie.replace(/;\s*Secure/gi, "");

            if (!adjustedCookie.includes("Path=")) {
              adjustedCookie += "; Path=/";
            }

            if (!adjustedCookie.includes("SameSite=")) {
              adjustedCookie += "; SameSite=Lax";
            }

            return adjustedCookie;
          });
        }
      },
      onError: (err, req, res) => {
        // eslint-disable-next-line no-console
        console.error(`[Proxy Error] ${err.message}`);
        // eslint-disable-next-line no-console
        console.error(
          `[Proxy Error] Certifique-se de que o backend está rodando em ${backendUrl}`,
        );

        if (res && !res.headersSent) {
          res.status(502).json({
            error: "Proxy error",
            message: `Não foi possível conectar ao backend em ${backendUrl}`,
          });
        }
      },
      logLevel:
        process.env.REACT_APP_CLIENT_LOG_LEVEL === "debug" ? "debug" : "warn",
    });

    app.use("/api", apiProxy);
    app.use("/oauth2", apiProxy);
    app.use("/login", apiProxy);
  } else {
    // eslint-disable-next-line no-console
    console.log(`[setupProxy] Usando configuração de proxy do package.json`);
    // eslint-disable-next-line no-console
    console.log(`[setupProxy] Backend esperado em: ${backendUrl}`);
  }
};
