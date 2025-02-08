# Starting over

I  cannot access the website (hosted on linode instance running podman) locally or on another network despite many attempts to troubleshoot and rebuild. In overview, I have validated the A record for the domain name, ran CURL commands to check on the cert status, rebuilt the image like 15 times. I believe we have narrowed this down to issues getting a cert in both prod and staging lets encrypt from the logs of the podman instance. I'm unable to get the letsencrypt cert function of Caddy to work, nor can I access the website. The Caddyfile has been validated multiple times. 

After multiple attempts to solve this issue, I am going to start over from scratch here. 

# Troubleshooting

## 1. Checked for Caddyfile descrepencies 
I checked for Caddyfile descrepencies between the host and volume mapping in podman as a last ditch effort to solve this. 

### a. Container

View Caddy File

```
podman exec -it caddy cat /etc/caddy/Caddyfile
```

Results (Staging) 

```
p.space, www.p.space  {
    root * /var/www
    file_server
    tls email@email.com {
        server https://acme-staging-v02.api.letsencrypt.org/directory
    }
}
```

### b. Host

View Caddy File

```
cat /etc/caddy/Caddyfile
```

Results

```
p.space, www.p.space {
    root * /var/www
    file_server
    tls {
        issuer acme {
            ca https://acme-staging-v02.api.letsencrypt.org/directory
            email name@email.com
        }
    }
}
```

## 2. Validated the format of the caddy file. there is more than on Caddyfile which is causing an issue. So I will clear out and start over. 

### 1. Remove all podman containers images, networks, and volumes

This command removes all containers, including running ones, using the force (-f) and all (-a) options

```
podman rm -f -a
podman system prune -a --volumes -f
```

### 2. CLear logs - this was not successful

```
sudo journalctl --vacuum-time=1s -u podman-container-caddy.service

```

## 4. NUKE and PAVE

### a. Remove the linode, create a new one. use the script ( podman_caddy_setup )to update the machine, install podman, and setup the podman container. 

At this point podman is installed, the host machine is up to date and has been rebooted. 

### b. Remaining Steps

1. The container and volumnes need to be built
2. The Caddyfile needs to be created/updated and needs to be on the container in the correct location
3. Create Simple index.html, make sure its where its suppose to be
4. Verify that the https certs are working with curl
5. Attempt with Browser
6. These step should be combined/compared with the steps in the script

### b. Once done document and script. 

## 5. Script improvements

### 1. Adjust podman compose settings in the script to match the podman command we have been running. 

```
podman run -d \
--name caddy-server \
--restart=always \
-v $(pwd)/Caddyfile:/etc/caddy/Caddyfile:Z \
-v ~/html:/var/www:Z \
-p 80:80 \
-p 443:443 \
docker.io/caddy:latest
```

### 2. Validate podman and container are all good
### 3. Check for the existance of other Caddy files
