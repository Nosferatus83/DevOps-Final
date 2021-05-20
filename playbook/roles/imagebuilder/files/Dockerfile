FROM tomcat:latest
RUN apt-get update
RUN apt-get install maven -y
RUN apt-get install git -y

#Repo clone, webapp build
#RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
RUN git clone https://github.com/Nosferatus83/DevOps-Final-App.git
#RUN cd ./boxfuse-sample-java-war-hello &&  mvn package
#RUN cp ./boxfuse-sample-java-war-hello/target/hello-1.0.war ./webapps/
RUN cd ./DevOps-Final-App &&  mvn package war:war
RUN cp ./DevOps-Final-App/target/Puzzle15-1.0-SNAPSHOT.war ./webapps/puzzle15.war

EXPOSE 8080

