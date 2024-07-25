@ECHO OFF

IF EXIST TestCA (
  rd TestCA /S/Q
)

MKDIR TestCA
@COPY /y nul TestCA\index.txt
@ECHO 01 > TestCA\serial
MKDIR TestCA\newcerts

@SET OPENSSL_CONF=E:\Source\CapsuleSignKey\openssl.cfg

@ECHO Start to generate Root CA
@PAUSE
::
:: Generate the Root Pair:
:: Sample Pass phase: TESTROOT
::
CALL openssl genrsa -aes256 -out TestRoot.key 3072

::
:: Generate a self-signed root certificate:
::
CALL openssl req -extensions v3_ca -new -x509 -days 3650 -key TestRoot.key -out TestRoot.crt
CALL openssl x509 -in TestRoot.crt -out TestRoot.cer -outform DER
CALL openssl x509 -inform DER -in TestRoot.cer -outform PEM -out TestRoot.pub.pem

@ECHO Start to generate Intermediate CA
@PAUSE
::
:: Generate the intermediate key:
:: Sample Pass phase: TESTSUB
::
CALL openssl genrsa -aes256 -out TestSub.key 3072

::
:: Generate the intermediate certificate:
::
CALL openssl req -new -key TestSub.key -out TestSub.csr
CALL openssl ca -extensions v3_intermediate_ca -in TestSub.csr -days 3650 -out TestSub.crt -cert TestRoot.crt -keyfile TestRoot.key
CALL openssl x509 -in TestSub.crt -out TestSub.cer -outform DER
CALL openssl x509 -inform DER -in TestSub.cer -outform PEM -out TestSub.pub.pem

::
:: Generate User Key Pair for Data Signing:
:: Sample Pass phase: TESTCERT
::
CALL openssl genrsa -aes256 -out TestCert.key 3072

@ECHO Start to generate User certificate
@PAUSE
::
:: Generate User certificate:
::
CALL openssl req -new -key TestCert.key -out TestCert.csr
CALL openssl ca -extensions usr_cert -in TestCert.csr -days 3650 -out TestCert.crt -cert TestSub.crt -keyfile TestSub.key
CALL openssl x509 -in TestCert.crt -out TestCert.cer -outform DER
CALL openssl x509 -inform DER -in TestCert.cer -outform PEM -out TestCert.pub.pem

@ECHO Remove the password
@PAUSE
::
:: Convert Key and Certificate for signing.
:: Password is removed with -nodes flag for convenience in this sample.
::
CALL openssl pkcs12 -export -out TestCert.pfx -inkey TestCert.key -in TestCert.crt
CALL openssl pkcs12 -in TestCert.pfx -nodes -out TestCert.pem
