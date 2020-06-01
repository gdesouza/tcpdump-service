# tcpdump-service

A simple service for tcpdump capture. Use this if you need continuous tcp monitoring on a server/computer.

This program is only supported on deb based Linux distributions.

## Configuration

The parameter for TCP dump are stored in the configuration file: `/etc/tcpdump.yaml`.
Current supported tcpdump flags:
- -G: rotate_seconds
- -W: filecount 

> Note that the file parameter below is mandatory since tcpdump will be running in background.

```
tcpdump:
  # any interface
  interface: "any"        

  # rotate each 12 hours
  rotate_seconds: 43200   
  
  filecount: 10
  file: /tmp/tcpdump-%Y-%m-%d-%H-%M.pcap
```

## Build

The build script provided will create a debian package to be distributed and installed.

```
cd tcpdump-service
./make_package.sh
sudo dpkg -i release/tcpdump-service-<version>.deb
```
