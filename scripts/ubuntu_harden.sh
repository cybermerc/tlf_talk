#!/bin/bash

# drop output of this run to file
# exec > /root/hardening_script_output.txt
# exec 2>&1

# apt-get update/upgrade all the things
/usr/bin/apt-get -qy update
/usr/bin/apt-get -qy dist-upgrade

# setup unattended upgrades
/usr/bin/apt-get -qy install unattended-upgrades
echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades
/etc/init.d/unattended-upgrades restart

# create user bob
useradd bob --create-home --shell /bin/bash
# add bob's SSH key
mkdir /home/bob/.ssh
chmod 700 /home/bob/.ssh
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/oSh4eYONo/pc1T1vDpwLPBfakvL3ZEo3soaQL9zRVe+RUThoivR33Wr44BYlJa/FjRFZiqNDxOui9Wp5Td0/TUHoIJnXqlpqvHmiOkL7EXPJB7e+zfSTCCALBjxk/ZIfJFHS/5rLtPJnGdasqK+nqT8KG+B6fHJ5VT4MDNIM7GDkedr6DDF/XB1wZepETFWh2AF0S0mmvzZ8hLge/LB4UjrgOcEiPkt62OAir3xMs6m7Jsr0SpQA/wejyhUSNbc+UsLxLAv3Y0529StfDo9CxAKTjwbpNPe9J7c8p4TZGfYMJlJ3SFUvKgl+ZFlqNIP3JNaN2o/5uJ7JHQdAaNHB bob@example.com" >> /home/bob/.ssh/authorized_keys
chown bob:bob /home/bob/.ssh -R
chmod 600 /home/bob/.ssh/authorized_keys
# give bob sudo access w/o passwd
echo -e "bob ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# setup ntpd
apt-get -y install ntp
# set time to US/Central
rm /etc/localtime
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
/etc/init.d/ntp restart

# set MOTD message
echo -e "#####################################\nWarning!!!! Security is Important\n#####################################\n\n\n" >> /etc/motd

# disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf

# install logwatch(this assumes you already have a functioning mail forwarder setup)
DEBIAN_FRONTEND=noninteractive apt-get -qy install logwatch

# harden SSH configurations
rm /etc/ssh/sshd_config
cat > /etc/ssh/sshd_config << EOL
Port 22
ListenAddress 0.0.0.0
# Force SSHv2 Protocol
Protocol 2
# HostKeys for protocol version 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
# Privilege Separation is turned on for security
UsePrivilegeSeparation yes
# Deny all other users besides the following
AllowUsers bob
# Client timeout (5 minutes)
ClientAliveInterval 300
ClientAliveCountMax 0
# Compression (only after authentication)
Compression delayed
# Logging
SyslogFacility AUTH
LogLevel INFO
# Authentication must happen within 30 seconds
LoginGraceTime 30
# Disable root SSH access
PermitRootLogin no
PermitEmptyPasswords no
# Check user folder permissions before allowing access
StrictModes yes
# Public key authentication
RSAAuthentication yes
PubkeyAuthentication yes
PasswordAuthentication no
AuthenticationMethods publickey
AuthorizedKeysFile	%h/.ssh/authorized_keys
MACs hmac-sha2-512,hmac-sha2-256
Ciphers aes256-cbc,aes256-ctr
KexAlgorithms ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256
# Don’t read the user’s ~/.rhosts and ~/.shosts files
IgnoreRhosts yes
# Disable unused authentication schemes
RhostsRSAAuthentication no
HostbasedAuthentication no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
UsePAM no
# X11 support
X11Forwarding no
# show Message of the Day
PrintMotd yes
# Allow client to pass locale environment variables
AcceptEnv LANG LC_*
EOL

# reboot server to ensure new kernel etc is in place
shutdown -r now
