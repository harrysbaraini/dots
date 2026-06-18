# Local Development Infrastructure

A self-contained dev stack that gives every local project its own `*.test`
hostname with a real, browser-trusted HTTPS certificate — no port juggling,
no `/etc/hosts` edits, no public DNS.

## Stack

| Service     | Image                                | Purpose                                                          |
|-------------|--------------------------------------|------------------------------------------------------------------|
| `step-ca`   | `smallstep/step-ca`                  | Private ACME-capable certificate authority                       |
| `caddy`     | `lucaslorentz/caddy-docker-proxy`    | Reverse proxy; obtains certs from `step-ca` via ACME            |
| `local-dns` | `coredns/coredns`                    | Resolves `*.test` to `127.0.0.1` (host) or `192.168.80.4` (containers) |
| `bastion`   | `lscr.io/linuxserver/openssh-server` | SSH jump host for tunneling into the docker network              |

All containers attach to an external Docker network called `global`
(`192.168.80.0/24`) so Caddy and step-ca can reach each other on stable IPs.

## Prerequisites

- Docker + Docker Compose
- [mise](https://mise.jdx.dev) (optional but recommended — all tasks below use it)
- macOS or Linux

## First-time setup

> The order matters: containers must be running before the ACME provisioner
> can be added, and the root CA must be trusted before browsers will accept
> the issued certs.

### 1. Create the network and start the stack

```bash
mise run start
```

This creates the `global` Docker network (if missing) and brings up
`docker-compose.yml`. On the very first run, `step-ca` initializes its root
and intermediate CAs into `./step-ca/`.

### 2. Register the ACME provisioner on step-ca

`step-ca` only ships with a JWK admin provisioner. Caddy needs a separate
**ACME** provisioner named `local-dev-acme` (the name is hard-coded in
Caddy's global options in `docker-compose.yml`).

```bash
mise run add-acme-ca
```

Under the hood:

```bash
docker exec -it step-ca step ca provisioner add local-dev-acme --type ACME \
  --x509-default-dur=87000h --x509-max-dur=87000h
docker compose restart step-ca
```

> Step-ca's ACME default is **24 hours** — fine for production with
> automated renewal, miserable for a dev box that sometimes sleeps for a
> week. The `--x509-default-dur=87000h` flag bumps issued certs to **~9.9
> years** (the ceiling is the intermediate CA's own validity, ~10y by
> default). Browsers normally cap publicly-trusted certs at 398 days, but
> that limit is **explicitly waived for user-installed root CAs** like
> `LocalDevCA`, so 10-year leaf certs validate fine in Chrome / Safari /
> Firefox once the root is trusted.

> ⚠️ **If you ever wipe `./step-ca/`** (e.g. `docker compose down -v` or
> deleting the directory), the CA reinitializes and this step must be repeated
> — otherwise Caddy will log ACME errors and never issue certificates.

### 3. Trust the root CA on the host

The root CA (stored in the `step_ca_certs` Docker volume) must be added to
your OS trust store, otherwise browsers show **`ERR_CERT_AUTHORITY_INVALID`**.

**macOS:**
```bash
mise run trust-cert
```

Equivalent to:
```bash
CERT=$(mktemp)
docker compose exec step-ca cat /home/step/certs/root_ca.crt > "$CERT"
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT"
rm "$CERT"
```

**Firefox** (any OS) keeps its own trust store. After installing the CA
system-wide, also run:
```bash
./scripts/install-step-ca.sh
```
which uses `certutil` (`brew install nss`) to inject the CA into every Firefox
profile.

> After trusting, **fully quit your browser** (⌘Q on macOS) and reopen — Chrome
> and Safari cache the cert chain per session.

### 4. Point your system at the local DNS

CoreDNS listens on `127.0.0.1:53` and answers any `*.test` query with the
Caddy IP.

**macOS:**
```bash
mise run install-resolver-macos
```
Creates `/etc/resolver/test` containing `nameserver 127.0.0.1`.

**Linux (systemd-resolved):**
```bash
mise run install-resolver-linux
```

Flush the DNS cache afterwards:
```bash
# macOS
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

# Linux
sudo systemd-resolve --flush-caches
```

### 5. Verify

```bash
dig myproject.test @127.0.0.1 +short          # → 127.0.0.1
mise run test-https                            # HTTPS cert trusted?
```

## Adding a project

Attach your project's web container to the `global` network and add two
Caddy labels — hostname and upstream port. No ports need to be published,
no TLS config needed (Caddy handles it automatically via step-ca).

```yaml
# myproject/docker-compose.yml
services:
  app:
    image: your-app-image
    networks: [global]
    labels:
      caddy: myproject.test
      caddy.reverse_proxy: "{{upstreams 80}}"

networks:
  global:
    external: true
```

Caddy detects the new container, requests a cert from step-ca via ACME, and
starts serving HTTPS within a few seconds. The first request to a new hostname
may see a 1–2 second delay while the cert is issued.

See `examples/project-docker-compose.yml` for a fuller template.

### Trusting the CA inside a project container

Containers that call other `*.test` services over HTTPS need to trust the
local root CA. Mount `step_ca_root_crt` at `/usr/local/share/ca-certificates/`
— it contains a single file `local-dev.crt` — then run `update-ca-certificates`
once at container startup:

```yaml
# myproject/docker-compose.yml
services:
  app:
    volumes:
      - step_ca_root_crt:/usr/local/share/ca-certificates/
    command: sh -c "update-ca-certificates && exec your-app"

volumes:
  step_ca_root_crt:
    external: true
```

> **Why a directory mount, not a file mount?** Docker named volumes are always
> directories. Mounting `step_ca_root_crt:/usr/local/share/ca-certificates/local-dev.crt`
> would create a *directory* named `local-dev.crt`, which `update-ca-certificates`
> cannot process. The correct target is the parent directory.

For curl without `update-ca-certificates`, or for Node.js, see the comments
in `examples/project-docker-compose.yml`.

### Backend uses HTTPS with a self-signed cert

If your container's internal service speaks HTTPS with a self-signed cert,
tell Caddy to skip verification for that upstream:

```yaml
labels:
  caddy: myproject.test
  caddy.reverse_proxy: "{{upstreams 443}}"
  caddy.reverse_proxy.transport: http
  caddy.reverse_proxy.transport.tls_insecure_skip_verify:
```

## Daily operations

| Task                  | Command                  |
|-----------------------|--------------------------|
| Start                 | `mise run start`         |
| Stop                  | `mise run stop`          |
| Restart               | `mise run restart`       |
| Tail logs             | `mise run logs`          |
| Container status      | `mise run status`        |
| Test DNS              | `mise run test-dns`      |
| Test HTTPS trust      | `mise run test-https`    |
| Force cert re-issue   | `mise run renew-certs`   |
| Migrate bind→volumes  | `mise run migrate-to-volumes` |
| Wipe everything       | `mise run clean`         |

`mise tasks` lists everything.

## Troubleshooting

### Browser shows `ERR_CERT_AUTHORITY_INVALID`

Either the root CA isn't trusted, or Caddy never issued a cert.

1. Confirm step-ca has the ACME provisioner:
   ```bash
   docker exec step-ca step ca provisioner list | grep -A1 local-dev-acme
   ```
   No output → re-run `mise run add-acme-ca`.

2. Confirm Caddy isn't logging ACME errors:
   ```bash
   docker logs caddy --tail 50 | grep -iE 'acme|certificate|error'
   ```

3. Confirm the root CA is in your keychain:
   ```bash
   security find-certificate -c LocalDevCA /Library/Keychains/System.keychain
   ```
   No match → re-run `mise run trust-cert` and restart your browser.

4. Verify the leaf cert is valid against the root from the CLI:
   ```bash
   CERT=$(mktemp) && docker compose exec step-ca cat /home/step/certs/root_ca.crt > "$CERT"
   curl -I --cacert "$CERT" https://debug.test/
   ```
   200/4xx here means certs are good and the issue is purely browser trust.

### `*.test` hostnames don't resolve in the browser

`dig myproject.test @127.0.0.1` works but the browser doesn't:
- macOS: confirm `/etc/resolver/test` exists with `nameserver 127.0.0.1`.
- Flush the DNS cache (commands above).
- Some browsers (Chrome) maintain their own DNS cache —
  visit `chrome://net-internals/#dns` and clear it.

### Port 53 already in use

macOS sometimes binds 53 via mDNSResponder for split-DNS. The simplest fix
is to keep CoreDNS bound to 53 (it works in practice on standard installs);
otherwise change the host-side mapping in `docker-compose.yml` and update
`/etc/resolver/test` to `nameserver 127.0.0.1` with `port <new>`.

### Caddy isn't routing to my container

- The container must be on the `global` network.
- The labels must include `caddy` (with the hostname) and `caddy.reverse_proxy`.
- Check Caddy logs: `docker logs caddy --tail 50`.

### Browser shows `ERR_CERT_DATE_INVALID`

The cached leaf cert has expired. Either step-ca was issuing 24-hour certs
(the default before `--x509-default-dur` is applied), or you genuinely went
~10 years without touching this stack.

```bash
mise run renew-certs   # clears Caddy's cert store and restarts
```

If certs were originally issued before you ran `mise run add-acme-ca` with
the duration flags, also re-run `mise run add-acme-ca` so future certs get
the long duration.

### Reset step-ca from scratch

```bash
docker compose down -v   # removes step_ca_data, step_ca_certs, and caddy_data volumes
mise run start           # reinitializes the CA into fresh volumes
mise run add-acme-ca     # re-add the ACME provisioner
mise run trust-cert      # the root CA is new — re-trust it
```

## File layout

```
.
├── docker-compose.yml         # Stack definition
├── Corefile                   # CoreDNS zones for *.test
├── resolv.conf                # Mounted into step-ca so it uses local DNS
├── mise.toml                  # Task runner
├── scripts/
│   └── install-step-ca.sh     # Trust root CA in macOS keychain + Firefox
└── examples/
    └── project-docker-compose.yml
```

Named Docker volumes (managed by Compose, not host paths):

| Volume | Contents | Mount in projects |
|---|---|---|
| `step_ca_data` | step-ca config, private keys, DB | — |
| `step_ca_certs` | `root_ca.crt`, `intermediate_ca.crt` | — |
| `step_ca_root_crt` | `local-dev.crt` (root cert, ready to drop in) | `/usr/local/share/ca-certificates/` |
| `caddy_data` | Caddy TLS state and ACME account | — |

## Notes

- The `.test` TLD is reserved by [RFC 2606](https://datatracker.ietf.org/doc/html/rfc2606)
  and will never collide with public DNS.
- All issued certs chain back to your local `LocalDevCA` and are only
  trusted on machines where you've imported `step-ca/certs/root_ca.crt`.
- The bastion container exposes SSH on `:2222` using your
  `~/.ssh/id_ed25519.pub` and can be used to tunnel into the `global`
  Docker network from another machine.
- All state is stored in named Docker volumes — no host-path bind mounts for
  data. If you have an existing `./step-ca/` directory from a previous setup,
  run `mise run migrate-to-volumes` once to copy it into the named volumes.
- `step_ca_certs` contains **only public certs** — safe to mount read-only
  into any project container without exposing private keys.
- Caddy's cert store (`caddy_data`) survives restarts. To force re-issuance:
  `mise run renew-certs`.
