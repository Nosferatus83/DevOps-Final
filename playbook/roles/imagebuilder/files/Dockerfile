FROM tomcat:latest
RUN apt-get update
RUN apt-get install maven -y
RUN apt-get install git -y
#Repo clone, webapp build
RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
RUN cd ./boxfuse-sample-java-war-hello &&  mvn package
RUN cp ./boxfuse-sample-java-war-hello/target/hello-1.0.war ./webapps/
EXPOSE 8080
