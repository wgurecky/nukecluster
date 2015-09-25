cp  /setup/mcnpv61/MCNP_DATA.zip /usr/share/mcnp/v6/.
unzip /usr/share/mcnp/v6/MCNP_DATA.zip
mv /usr/share/mcnp/v6/MCNP_DATA /usr/share/mcnp/v6/lib

# change the file permissions on the mcnp6 and mcnp6data directories
chmod -R o-x /usr/share/mcnp/v6
chmod -R o-r /usr/share/mcnp/v6
chgrp -R mcnp6 /usr/share/mcnp/v6
