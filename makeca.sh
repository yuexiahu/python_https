# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# * Neither the name of the axTLS project nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# Generate the certificates and keys for testing.
#

# ca目录: 保存ca的私钥ca.key和自颁发证书ca.crt
# certDER目录: 将证书保存为二进制文件 ca.der client.der server.der
# client目录: 客户端证书client.crt 客户端私钥client.key
# server目录: 服务端证书server.crt 服务端私钥server.key


PROJECT_NAME="TLS Project"
SERVER_CN="localhost"
CLIENT_CN="localhost"

# Generate the openssl configuration files.
cat > ca_cert.conf << EOF  
[ req ]
distinguished_name     = req_distinguished_name
prompt                 = no

[ req_distinguished_name ]
 O                      = $PROJECT_NAME Dodgy Certificate Authority
EOF

cat > server_cert.conf << EOF  
[ req ]
distinguished_name     = req_distinguished_name
prompt                 = no

[ req_distinguished_name ]
 O                      = $PROJECT_NAME
 CN                     = $SERVER_CN
EOF

cat > client_cert.conf << EOF  
[ req ]
distinguished_name     = req_distinguished_name
prompt                 = no

[ req_distinguished_name ]
 O                      = $PROJECT_NAME Device Certificate
 CN                     = $CLIENT_CN
EOF

mkdir -p ca
mkdir -p server
mkdir -p client

# private key generation
openssl genrsa -des3 -out ca.key 4096
openssl genrsa -des3 -out server.key 4096
openssl genrsa -des3 -out client.key 4096

# cert requests
openssl req -out ca.req -key ca.key -new \
            -config ./ca_cert.conf
openssl req -out server.req -key server.key -new \
            -config ./server_cert.conf 
openssl req -out client.req -key client.key -new \
            -config ./client_cert.conf 

# generate the actual certs.
openssl x509 -req -in ca.req -out ca.crt \
            -sha256 -days 5000 -signkey ca.key
openssl x509 -req -in server.req -out server.crt \
            -sha256 -CAcreateserial -days 5000 \
            -CA ca.crt -CAkey ca.key
openssl x509 -req -in client.req -out client.crt \
            -sha256 -CAcreateserial -days 5000 \
            -CA ca.crt -CAkey ca.key

openssl x509 -in ca.crt -outform DER -out ca.der
openssl x509 -in server.crt -outform DER -out server.der
openssl x509 -in client.crt -outform DER -out client.der

mv ca.crt ca.key ca/
mv server.crt server.key server.pem server/
mv client.crt client.key client.pem client/

mv ca.der server.der client.der certDER/

rm *.conf
rm *.req
rm *.srl 
