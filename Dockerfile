# build environment
FROM node:10.16.0 as builder

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

ENV PATH /usr/src/app/node_modules/.bin:$PATH

COPY . /usr/src/app
#COPY package.json /usr/src/app/package.json
RUN npm install -g @angular/cli@8.0.6 --unsafe
RUN npm install

RUN npm build --output-path=dist

FROM httpd:2.4-alpine

# copy compiled app to server
COPY --from=builder /usr/src/app/dist/hygieia-ui /usr/local/apache2/htdocs/
COPY ./httpd/.htaccess /usr/local/apache2/htdocs/.htaccess
COPY startup.sh startup.sh

RUN apk update
RUN apk upgrade
RUN apk add bash

#configure Proxy Rewrite to find backend based on passed in API_URL
RUN sed -in 's/#LoadModule proxy_module/LoadModule proxy_module/' /usr/local/apache2/conf/httpd.conf
RUN sed -in 's/#LoadModule proxy_http_module/LoadModule proxy_http_module/' /usr/local/apache2/conf/httpd.conf
RUN sed -in 's/#LoadModule ssl_module/LoadModule ssl_module/g' /usr/local/apache2/conf/httpd.conf
RUN sed -in '/<Directory \"\/usr\/local\/apache2\/htdocs\">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /usr/local/apache2/conf/httpd.conf
RUN sed -in 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /usr/local/apache2/conf/httpd.conf
RUN chmod +x startup.sh

# expose port 80
EXPOSE 80

#ENTRYPOINT ["./startup.sh"]
CMD [ "bash", "httpd-foreground" ]