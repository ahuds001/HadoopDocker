FROM sequenceiq/hadoop-docker:latest
# install wget
RUN yum -y install wget
#install HBase
RUN cd usr/local/ && wget http://apache.claz.org/hbase/stable/hbase-1.2.2-bin.tar.gz \
	&& tar -xzvf hbase-1.2.2-bin.tar.gz
ENV HBASE_HOME /usr/local/hbase-1.2.2-bin
ENV PATH $HBASE_HOME/bin:$PATH
#install Hive
RUN cd /usr/local/ && wget  http://apache.claz.org/hive/hive-2.1.0/apache-hive-2.1.0-bin.tar.gz && \
	 tar -xzvf apache-hive-2.1.0-bin.tar.gz  
ENV HIVE_HOME /usr/local/apache-hive-2.1.0-bin
ENV PATH $HIVE_HOME/bin:$PATH
#support for Hadoop 2.7.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-hadoop2.7.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-2.0.0-bin-hadoop2.7 spark
ENV SPARK_HOME /usr/local/spark 
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client
RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && \
	$HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-2.0.0-bin-hadoop2.7/jars /spark
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop 
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin 
# update boot script 
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh
#install R 
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install R
#install Python
ENV ANACONDA_HOME /usr/local/anaconda 
RUN cd /usr/local && wget http://repo.continuum.io/archive/Anaconda2-4.1.1-Linux-x86_64.sh \
	&& bash Anaconda2-4.1.1-Linux-x86_64.sh -b -p $ANACONDA_HOME 
ENV PATH $ANACONDA_HOME/bin:$PATH
ENTRYPOINT ["/etc/bootstrap.sh"]
