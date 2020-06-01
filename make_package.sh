#/bin/bash
#
# Make debian package
# Author: Gus de Souza

function check_result {
    if [ $? != 0 ]; then
        echo "Failed"
        exit 1
    fi
}

VERSION=$1
DIR=tcpdump-service-$VERSION
if [ -d $DIR ]; then
    echo "Removing old directory $DIR..."
    rm -rf $DIR
fi

echo "Creating directory $DIR..."
mkdir $DIR
check_result

echo "Copying files to $DIR..."
sudo rsync -a package/* $DIR/
check_result

echo "Creating package..."
dpkg-deb --build "$DIR"
check_result

echo "Moving package to release folder..."
rsync $DIR.deb release/ && rm $DIR.deb
check_result

echo "Removing build files..."
rm -rf $DIR
check_result

exit 0