FROM nginx
MAINTAINER EK TECH SOFTWARE SOLUTION
COPY . /usr/share/nginx/html
RUN rm -rf /usr/share/nginx/html/Jenk*
EXPOSE 80
