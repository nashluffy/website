locals {
  region = "us-central1"
  zone = "us-central1-a"
  vm_name = "website"
}

resource "google_compute_address" "static_ip" {
  name   = "${local.vm_name}-ip"
  region = local.region
}

resource "google_compute_firewall" "http_https" {
  name    = "${local.vm_name}-allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm" {
  name         = local.vm_name
  machine_type = "e2-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12" # debian 12
      size  = 30
    }
  }

  network_interface {
    network       = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  # Startup script will install docker & docker-compose and create docker-compose + Caddyfile
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    if ! command -v docker >/dev/null 2>&1; then
      curl -fsSL https://get.docker.com | sh
      usermod -aG docker ${USER}
    fi

    mkdir -p /usr/local/lib/docker/cli-plugins
    DOCKER_COMPOSE_BIN="/usr/local/lib/docker/cli-plugins/docker-compose"
    if [ ! -f "$DOCKER_COMPOSE_BIN" ]; then
      COMPOSE_LATEST=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
      curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_LATEST}/docker-compose-$(uname -s)-$(uname -m)" -o $DOCKER_COMPOSE_BIN
      chmod +x $DOCKER_COMPOSE_BIN
    fi

    APP_DIR="/opt/site"
    mkdir -p ${APP_DIR}
    chown ${USER}:${USER} ${APP_DIR}

    cat > ${APP_DIR}/docker-compose.yml <<EOF
    version: "3.8"

    services:
      app:
        image: ${var.app_image}
        restart: unless-stopped
        expose:
          - "${var.internal_port}"
        environment:
          - PORT=${var.internal_port}

      caddy:
        image: caddy:latest
        restart: unless-stopped
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - caddy_data:/data
          - caddy_config:/config
          - ./Caddyfile:/etc/caddy/Caddyfile
        depends_on:
          - app

    volumes:
      caddy_data:
      caddy_config:
    EOF

    cat > ${APP_DIR}/Caddyfile <<EOF
    ${var.domain} {
      reverse_proxy app:${var.internal_port}
    }
    EOF

    chown -R ${USER}:${USER} ${APP_DIR}

    cd ${APP_DIR}
    /usr/local/lib/docker/cli-plugins/docker-compose up -d

    # Ensure docker-compose is started on boot via systemd unit
    cat > /etc/systemd/system/website.service <<SYSTEMD
    [Unit]
    Description=Docker Compose for website
    After=network.target docker.service
    Requires=docker.service

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    WorkingDirectory=${APP_DIR}
    ExecStart=/usr/local/lib/docker/cli-plugins/docker-compose up -d
    ExecStop=/usr/local/lib/docker/cli-plugins/docker-compose down
    TimeoutStartSec=0

    [Install]
    WantedBy=multi-user.target
    SYSTEMD

    systemctl daemon-reload
    systemctl enable website.service
    systemctl start website.service || true

    echo "Startup finished"
  EOT

  tags = ["http-server","https-server"]
}

output "static_ip" {
  value = google_compute_address.static_ip.address
}

output "instance_name" {
  value = google_compute_instance.vm.name
}
