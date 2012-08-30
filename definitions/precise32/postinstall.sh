# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/travis_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-dev zlib1g-dev zlib1g libreadline6
apt-get clean

# Installing the virtualbox guest additions
apt-get -y install dkms linux-headers-3.2.0-29-generic-pae
VBOX_VERSION=$(cat /home/travis/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

pushd .
wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
tar xzvf yaml-0.1.4.tar.gz
cd yaml-0.1.4
./configure && make && make install
popd

# Install NFS client
apt-get -y install nfs-common

wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
tar xvzf ruby-1.9.3-p194.tar.gz
cd ruby-1.9.3-p194
./configure --prefix=/opt/ruby
LD_LIBRARY_PATH="/usr/lib:/usr/local/lib" make
make install
cd ..
rm -rf ruby-1.9.3*

# Install RubyGems
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz
tar xzf rubygems-1.8.24.tgz
cd rubygems-1.8.24
/opt/ruby/bin/ruby setup.rb
cd ..
rm -rf rubygems-1.8.24

# Installing Chef
/opt/ruby/bin/gem install chef --no-ri --no-rdoc

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby, RubyGems, and Chef/Puppet are visible
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/travisruby.sh

# Installing travis keys
mkdir /home/travis/.ssh
chmod 700 /home/travis/.ssh
cd /home/travis/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/travis/.ssh/authorized_keys
chown -R travis /home/travis/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/travis/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Remove items used for building, since they aren't needed anymore
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
