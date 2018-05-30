#!/bin/sh

# Definindo as variáveis

#Alias do certificado, pode ser preenchido à gosto
NAME=letsencript
#Domínio registrado no Lets Encrypt (ex. seusite.com.br)
DOMAIN=jpbx.com.br
#Senha do keystore, se você não alterou na criação do seu domain do Glassfish/Payara, então ela é "changeit"
KEYSTOREPW=changeit

LIVE=/etc/letsencrypt/live/$DOMAIN

# Criando diretório para conversão dos certificados

mkdir temp_cert
cd temp_cert

# Criando o keystore.jks

openssl pkcs12 -export -in $LIVE/cert.pem -inkey $LIVE/privkey.pem -out cert_and_key.p12 -name $NAME -CAfile $LIVE/chain.pem -caname root -password pass:$KEYSTOREPW

keytool -importkeystore -destkeystore keystore.jks -srckeystore cert_and_key.p12 -srcstoretype PKCS12 -alias $NAME -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW
keytool -import -noprompt -trustcacerts -alias root -file $LIVE/chain.pem -keystore keystore.jks -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

openssl pkcs12 -export -in $LIVE/fullchain.pem -inkey $LIVE/privkey.pem -out pkcs.p12 -name glassfish-instance -password pass:$KEYSTOREPW
keytool -importkeystore -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -alias glassfish-instance -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

openssl pkcs12 -export -in $LIVE/fullchain.pem -inkey $LIVE/privkey.pem -out pkcs.p12 -name s1as -password pass:$KEYSTOREPW
keytool -importkeystore -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -alias s1as -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

# Criando o cacerts.jks

openssl pkcs12 -export -in $LIVE/cert.pem -inkey $LIVE/privkey.pem -out cert_and_key.p12 -name $NAME -CAfile $LIVE/chain.pem -caname root -password pass:$KEYSTOREPW

keytool -importkeystore -destkeystore cacerts.jks -srckeystore cert_and_key.p12 -srcstoretype PKCS12 -alias $NAME -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW
keytool -import -noprompt -trustcacerts -alias root -file $LIVE/chain.pem -keystore cacerts.jks -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

openssl pkcs12 -export -in $LIVE/fullchain.pem -inkey $LIVE/privkey.pem -out pkcs.p12 -name glassfish-instance -password pass:$KEYSTOREPW
keytool -importkeystore -destkeystore cacerts.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -alias glassfish-instance -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

openssl pkcs12 -export -in $LIVE/fullchain.pem -inkey $LIVE/privkey.pem -out pkcs.p12 -name s1as -password pass:$KEYSTOREPW
keytool -importkeystore -destkeystore cacerts.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -alias s1as -srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW

# Listando as chaves

keytool -list -keystore keystore.jks -storepass $KEYSTOREPW
keytool -list -keystore cacerts.jks -storepass $KEYSTOREPW

# Fim

cd ..