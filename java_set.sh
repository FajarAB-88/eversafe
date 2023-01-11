#!/bin/bash
get_java_home() {
 export TEMP_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.*
 echo $TEMP_HOME
}
echo 'export JAVA_HOME='$(get_java_home)'' >> /home/eversafe/.bashrc
echo 'export PATH=$PATH:'$(get_java_home)'/bin' >> /home/eversafe/.bashrc
ln -s $(get_java_home)/jre/bin $(get_java_home)

