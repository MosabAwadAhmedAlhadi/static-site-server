# Static Site Server

A project from the [roadmap.sh DevOps Projects](https://roadmap.sh/projects/static-site-server) series.  
Host a static website on a remote Linux server using **Nginx** and deploy updates with **rsync** over SSH.

---

## 🚀 What this project demonstrates
- Installing and configuring **Nginx** (server block, sites-available → sites-enabled)
- Allowing HTTP traffic (UFW )
- Deploying static files using **rsync**
- (Optional) Simple deploy script with environment variables

---

## 🧰 Stack
Ubuntu • Nginx • rsync • SSH keys • UFW • AWS EC2

---

## ✅ Prerequisites
- EC2 Ubuntu instance with a public IP
- SSH key-based access (no passwords)

---

## 📋 Steps Implemented

### 1.Install Nginx

on the server:

```bash
sudo apt install nginx -y
sudo systemctl enable --now nginx
```
Quick check (on the server):
```bash
curl http://localhost
```
You should see the Nginx welcome HTML.

### 2.Create Web Root & Sample Page

```bash
sudo mkdir -p /var/www/mysite/html
sudo chown -R $USER:www-data /var/www/mysite
echo "<h1>Hello from Static Site Server</h1>" > /var/www/mysite/html/index.html
```

### 3.Nginx Server Block (sites-available → sites-enabled)
Configure nginx server block `/etc/nginx/sites-available/mysite` to point to your directory. Basic config example:
```nginx
server {
    listen 80;
    server_name <SERVER_IP> <YOUR_DOMAIN>;  # replace as needed

    root /var/www/mysite/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```
Enable it and (optionally) disable the default site:
```bash
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/mysite
# optional: remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# test & reload
sudo nginx -t
sudo systemctl reload nginx
```

### 4.Open HTTP (Port 80)
**UFW (on the server):**
```bash
sudo ufw allow 80/tcp
sudo ufw enable
sudo ufw status
```
Now http://<SERVER_IP> should load your sample page.

### 5.Deploy Static Files with rsync (from your local machine)
Basic one-liner:
```bash
rsync -avzP --delete ./site/ ubuntu@<SERVER_IP>:/var/www/mysite/html/
ssh ubuntu@<SERVER_IP> "sudo systemctl reload nginx"
```
- -a = archive mode (preserves permissions, timestamps)
- -z = compress during transfer
- -v → verbose (see what’s happening)
- -P = show progress and partial transfer support
- --delete = delete files on server not present locally
- The trailing slash on ./site/ means “copy the contents of site folder,” not the folder itself.

**Optional: use a `.env` and script**
`.env` (committed to Git an example):
```bash
SERVER_USER=<SERVER_USER_NAME>
SERVER_IP=<SERVER_IP>
SERVER_PATH=/var/www/mysite/html
LOCAL_SITE_PATH=./site/
```
now using the `deploy.sh` file from this repo:
```bash
chmod +x deploy.sh
./deploy.sh
```

### 6.Validate
 - Visit: `http://<SERVER_IP>`
 - Update a local file, redeploy, refresh browser → changes should be live.

----
## 📂 Project Structure
```bash
.
├── site/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── deploy.sh        # optional
├── .env             # optional (not committed)
└── README.md
```

## 🧪 Troubleshooting
 - **Still seeing the default page?** Remove `sites-enabled/default`, reload Nginx.
 - **403/404 errors?** Check `root` path matches `/var/www/mysite/html` and files exist.
 - **Connection timeouts?** Verify EC2 Security Group has port 80 open.
 - **Rsync deletes files unexpectedly?** Dry run first: `rsync -avzn --delete ...`
