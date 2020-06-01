#/bin/bash
DATE=`date '+%Y-%m-%d %H:%M:%S'`
echo "TCPDump service started at ${DATE}" | systemd-cat -p info


function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

if [ -f /etc/tcpdump.yaml ]; then
    eval $(parse_yaml /etc/tcpdump.yaml)
    INTERFACE=$tcpdump_interface
    OPTION=''
    if [ ! -z $tcpdump_rotate_seconds ]; then
        OPTIONS+=" -G $tcpdump_rotate_seconds "
    fi
    if [ ! -z $tcpdump_filecount ]; then
        OPTIONS+=" -W $tcpdump_filecount "
    fi
    if [ ! -z $tcpdump_file ]; then
        OUTPUT=" -w $tcpdump_file "
    fi
else
    INTERFACE='any'
    OUTPUT='-w /tmp/tcpdump-%Y-%m-%d-%H-%M.pcap'
    # -l Make stdout line buffered. Useful if you want to see the data while capturing it.
    # -tttt Print a timestamp, as hours, minutes, seconds, and fractions of a second since midnight, preceded by the date, on each dump line. 
    OPTIONS='-G 43200 -W 20'
fi

echo "Starting tcpdump service..."
tcpdump $OPTIONS -i $INTERFACE $OUTPUT
result=$?
if [ $result != 0 ]; then
    echo "tcpdump aborted with code $result"
    exit 1
fi