mkdir  -p /usr/local/redis-helper
cp redis-helper.sh /usr/local/redis-helper/redis-helper
chmod +x /usr/local/redis-helper/redis-helper
cp redis-helper.1 /usr/share/man/man1/
echo  'export PATH=$PATH:/usr/local/redis-helper' >> ~/.bashrc
source ~/.bashrc
