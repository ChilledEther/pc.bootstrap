# 1. Download the correct x86_64 version
curl -L "https://github.com/PowerShell/DSC/releases/download/v3.1.2/dsc-3.1.2-x86_64-unknown-linux-gnu.tar.gz" -o dsc.tar.gz

# 2. Extract it
tar -xzf dsc.tar.gz

# 3. Move it to your path (overwriting the bad one)
sudo mv dsc /usr/local/bin/dsc
sudo chmod +x /usr/local/bin/dsc

# 4. Cleanup
rm dsc.tar.gz