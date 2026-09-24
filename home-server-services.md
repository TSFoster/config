# Deploying a service onto the home server

Services are deliberately **not** managed from this repo — each one is its own separately-managed
Docker Compose project. This repo only owns the host itself: Docker Engine, the shared data mount,
Tailscale + DockTail, Traefik, and unattended-upgrades (see `roles/`). This doc is the contract a
service's own compose project needs to follow to plug into that host correctly.

## Shared storage

Bind-mount under `{{ base_data }}` (see `host_vars/home_server/vars.yml`) and give the container
`group_add: ["2000"]` (the `svc` group set up by `roles/service_data`) so multiple services can
share write access to common paths without fighting over ownership.

## Internal (tailnet-only) access

DockTail (`roles/docktail`) watches the Docker socket, but it only advertises containers that
opt in via labels — add `docktail.service.*` labels to advertise a port as a tailnet Service.
Example from `uptime`'s compose file:

```yaml
labels:
  - "docktail.service.enable=true"
  - "docktail.service.name=uptime"
  - "docktail.service.port=8080"
  - "docktail.service.service-protocol=https"
  # additional ports on the same container: repeat with an index prefix
  - "docktail.service.1.name=uptime"
  - "docktail.service.1.port=8080"
  - "docktail.service.1.service-protocol=http"
```

## Public (semi-public) access

1. Join the external `edge` Docker network (created by `roles/traefik`):

   ```yaml
   services:
     myservice:
       # ...
       networks:
         - edge

   networks:
     edge:
       external: true
   ```

2. Add Traefik routing labels (the docker provider is `exposedByDefault: false`, so nothing is
   exposed without these):

   ```yaml
   labels:
     - traefik.enable=true
     - traefik.http.routers.myservice.rule=Host(`myservice.example.com`)
     - traefik.http.services.myservice.loadbalancer.server.port=8080
   ```

3. Run your own `cloudflared` container in the same compose project, also joined to the `edge`
   network, with an ingress rule pointing at Traefik rather than the service directly:

   ```yaml
   cloudflared:
     image: cloudflare/cloudflared:latest
     command: tunnel run
     environment:
       - TUNNEL_TOKEN=${CLOUDFLARE_TUNNEL_TOKEN}
     networks:
       - edge
   ```

   Configure that tunnel's public hostname (in the Cloudflare dashboard, or an `ingress:` block in
   its own config) to forward to `http://traefik:80` with the same `Host` used in the Traefik router
   rule above. Traefik does the actual routing/TLS-termination-adjacent work from there; nothing
   needs a host port published, and the server's firewall (`roles/firewall`) doesn't need any new
   rule for this — the tunnel is entirely outbound.

Each service manages its own `cloudflared` tunnel credentials/token — this repo has no Cloudflare
configuration of its own.
