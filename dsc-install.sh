cd /tmp && \
curl -L "https://github.com/PowerShell/DSC/releases/download/v3.1.2/DSC-3.1.2-x86_64-linux.tar.gz" -o dsc.tar.gz && \
tar -xzf dsc.tar.gz && \
sudo mv dsc /usr/local/bin/dsc && \
sudo chmod +x /usr/local/bin/dsc && \
rm dsc.tar.gz && \
dsc --version