docker-redis
============

Builds a simple Redis container.  I needed this for my 
[gitlab](https://github.com/oskapt/docker-gitlab) container, and other
than building it, I did no configuration.

To run it, change into the `docker_files/run` directory and execute 
`run.sh` as root.  If you want to inspect the container, use the `-sf`
option to bring it up with a shell and attach to it.  From there you 
can manually run `/start` to fire up Redis.  

If you want to control Redis when running in detached mode, 
supervisor listens on port 9999 (use `docker ps` to find out where
that was mapped).  The username is `docker` and the password is `d0ck3r`.  
You can change these in `docker.conf` before building the container.

Enjoy.

