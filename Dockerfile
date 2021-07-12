# Create Custom Docker Image
# Pull tomcat latest image from dockerhub 
FROM tomcat:latest




# copy war file on to container 
COPY ./webapp.war /usr/local/tomcat/webapps
