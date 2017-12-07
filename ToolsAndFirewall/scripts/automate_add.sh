useradd automate
touch /etc/sudoers.d/automate
echo "%automate ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/automate
echo "Defaults:%automate    !requiretty" >> /etc/sudoers.d/automate
chmod 0440 /etc/sudoers.d/automate


mkdir -p /home/automate/.ssh
touch /home/automate/.ssh/authorized_keys
chown -R automate:automate /home/automate/
chmod -R 700 /home/automate/
chmod -R 700 /home/automate/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhBgKlasNfiKfOYm8LveMPNpdNyOt1Fzlc1x23fyxr+nD/23m6u8p13ZPkU+qHjTgVvmkq74HDOx8STe4GUoLpZKpN1ab5bIN3kNbINw5QRu1duEiwFuCQ5LEoptSLNOZ/HQDZYeBQ84Sfjvg5lVQ6SXRDwus4XIVWxRaZ3vuxC8erGMnDk9DJiQoEbOeAmKj3kkPgvOdm8xR66ZdSEiIQQMvqJpaTWjghLZCBD2uv16auKi0rweJePrH0Y/s0xYf8g/x2iR5M/BZt+SGsCbAI8ecK+FV+Z6i/b8jPgbMVco6/wkrYnqjVJQ+nbuvL0qpdB+D6Rv3eyXi6nQZ8VG8NgpRm2VE6t8Rx9BWNCcoh515JrGtx+4dQ+9OVCBjfM+S0mrha1r4iKZTmnd1X+6J0Y/N8cw+IPd/9djtVr+UtODnSK/inx+CLyjTw/BXbI/p9yK5CAAbOJL6XYn3u67Fg5rJBp5zL4eLcWWLleZAdMB6t1+OEdIH/d9B/nk9gcmqh//MHtT+I9QF3qBiShMPO8vlnHFFKE835DnZ0/HDSUTBRW/83oAZ/Q5owteEbfGNNV5m960LWY17UJ2rXK/7g3MgpXbFW/hMve/UtAV1VCXOW0y548YNclDr5x0RpG6lX+0FZkKtl3rHbySGu5lq736cz+ah67IJFn8UVlQjLlQ== !!897/I/8a6735/IBM/Joseph.Boyle!!" >> /home/automate/.ssh/authorized_keys
