if  [ ! -s /publicKey ]; then
# Export private key so alumno can connect externally via ssh
    ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
    cat ~/.ssh/id_rsa > /generatedKeys/private
    cat ~/.ssh/id_rsa.pub > /generatedKeys/public
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
else
    cat /publicKey >> ~/.ssh/authorized_keys
fi

# start ssh service
sudo /usr/sbin/sshd -D