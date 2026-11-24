"""Run the ChatDev FastAPI server on one dual-stack socket ([::] with IPv4 too).

Upstream's server_main.py binds a single host. Binding "::" through asyncio sets
IPV6_V6ONLY, so IPv4 clients fail; binding 0.0.0.0 misses Railway's IPv6 private
network. We pre-bind one socket that accepts both and hand it to uvicorn.
"""
import logging
import os
import socket
import sys

os.chdir("/app")
sys.path.insert(0, "/app")

level = os.environ.get("CHATDEV_LOG_LEVEL", "warning").lower()
os.environ["LOG_LEVEL"] = level.upper()
logging.basicConfig(level=getattr(logging, level.upper(), logging.WARNING),
                    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")

from runtime.bootstrap.schema import ensure_schema_registry_populated  # noqa: E402

ensure_schema_registry_populated()

import uvicorn  # noqa: E402

port = int(os.environ.get("PORT", "6400"))
sock = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
sock.bind(("::", port))
sock.listen(256)
print(f"chatdev: backend listening on [::]:{port} (IPv4 and IPv6)", flush=True)

config = uvicorn.Config("server.app:app", log_level=level, ws="wsproto", proxy_headers=True,
                        forwarded_allow_ips="*")
server = uvicorn.Server(config)
server.run(sockets=[sock])
# uvicorn returns normally after a signal; any other return is unexpected.
sys.exit(0 if server.should_exit else 1)
