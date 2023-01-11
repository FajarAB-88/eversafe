FROM centos:centos7.9.2009
LABEL description="Eversafe Update Manager"
RUN useradd eversafe -G wheel
RUN yum -y update \
    && yum -y install epel-release deltarpm \
    && yum -y groupinstall "Base", "Networking Tools", "Compatibility libraries" \
        "Hardware monitoring utilities", "Performance Tools", "Security Tools" \
    && yum -y install ipvsadm mc psmisc nload lsyncd nginx atop htop iftop ntp \
        p7zip ruby rubygems screen telnet xinetd autogen iperf python2-psutil numad nmon \
        nmap curl tcpdump wget \
    && systemctl enable rngd && systemctl enable numad
#os tuning
COPY selinux.config /etc/selinux/config
COPY sysctl.conf /etc/sysctl.conf
COPY limits.conf /etc/security/limits.conf
#locale
RUN localedef -v -c -i ko_KR -f UTF-8 ko_KR.UTF-8; exit 0
ADD locale.conf /etc/locale.conf
ADD .bash_profile /root/.bash_profile
RUN ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
#java
#RUN echo 'export PATH=$PATH:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.*/bin' >> /home/eversafe/.bashrc
#RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.*' >> /home/eversafe/.bashrc
COPY java_set.sh /home/eversafe/java_set.sh
RUN chmod +x /home/eversafe/java_set.sh && \
    sh /home/eversafe/java_set.sh && \
    #set owner each directory
    mkdir -p /home/eversafe/storage && \
    mkdir -p /home/eversafe/log && \
    mkdir -p /home/eversafe/eversafe_zookeeper/zkServers/zk1/data/version-2 && \
    mkdir -p /home/eversafe/eversafe_zookeeper/zkServers/zk2/data/version-2 && \
    chown -R eversafe.eversafe /home/eversafe/log && \
    chown -R eversafe.eversafe /home/eversafe/storage && \
    chown -R eversafe.eversafe /home/eversafe/eversafe_zookeeper && \
    chmod 777 /home/eversafe/storage
#nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY eversafe.conf /etc/nginx/conf.d/eversafe.conf
RUN setcap CAP_NET_BIND_SERVICE=+eip /sbin/nginx && \
    rm -rf /etc/logrotate.d/nginx && \
    chown -R eversafe:eversafe /etc/nginx && \
    chown -R eversafe:eversafe /usr/sbin/nginx && \
    chown -R eversafe:eversafe /usr/lib64/nginx && \
    chown -R eversafe:eversafe /usr/share/nginx && \
    chown -R eversafe:eversafe /var/lib/nginx && \
    chown -R eversafe:eversafe /var/log/nginx
RUN chown -R eversafe:eversafe /usr/lib64/perl5/vendor_perl/auto/nginx;exit 0
    
RUN su - eversafe -c "mkdir -p /home/eversafe/nginx.d/log"
RUN su - eversafe -c "mkdir /home/eversafe/nginx.d/cache"
#update manager
COPY eversafe-update-manager-* /home/eversafe
COPY start_nginx_eum.sh /home/eversafe
RUN su - eversafe -c "unzip -d /home/eversafe /home/eversafe/eversafe-update-manager-*" && \
    chown eversafe.eversafe /home/eversafe/start_nginx_eum.sh && \
    chmod +x /home/eversafe/start_nginx_eum.sh
CMD ["sh", "/home/eversafe/start_nginx_eum.sh"]