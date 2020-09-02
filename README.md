# amsu

### To build docker image
`$ docker build -t amatra/support:1 .`

### To run docker container and bind port 8080 & 8443
`$ docker run -d -p 8080:8080 -p 8443:8443 <image_id>`

### To show docker images
`$ docker images`

![image](/image1.png)

### To show docker container
`$ docker ps -a`

![image](/image2.png)

### To start docker container
`$ docker start <container_id>`

![image](/image3.png)

### To show docker container running
`$ docker ps`

![image](/image4.png)

### Copy mobilesales-config.properties file
```
$ docker exec -ti <image_id> bash
$ cp /opt/tomcat7/conf/mobilesales-config.properties /opt/tomcat7/webapps/mobilesales/WEB-INF/classes/
```

or from outside container terminal
```
docker exec <container_id> bash -c "cp /opt/tomcat7/conf/mobilesales-config.properties /opt/tomcat7/webapps/mobilesales/WEB-INF/classes/"
```

![image](/image5.png)

### Restart tomcat7
```
$ /opt/tomcat7/bin/shutdown.sh
$ /opt/tomcat7/bin/startup.sh
```

or from outside terminal
```
docker exec <container_id> bash -c "/opt/tomcat7/bin/shutdown.sh && /opt/tomcat7/bin/startup.sh"
```

![image](/image6.png)

> Run this docker on a server that has *.compnet.co.id domain<br>
> for example amatra.compnet.co.id<br>
> `$ curl https://amatra.compnet.co.id:8443/mobilesales/`

in Browser

![image](/image7.png)
