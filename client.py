import urllib.request

import ssl

if __name__ == '__main__':
    CA_FILE = "ca/ca.crt"
    KEY_FILE = "client/client.key"
    CERT_FILE = "client/client.crt"

    context = ssl.SSLContext(ssl.PROTOCOL_TLS)
    context.check_hostname = False
    context.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE, password='1234')
    context.load_verify_locations(CA_FILE)
    context.verify_mode = ssl.CERT_REQUIRED
    try:
        # 通过request()方法创建一个请求：
        request = urllib.request.Request('https://127.0.0.1:5000/')
        res = urllib.request.urlopen(request, context=context)
        print(res.code)
        print(res.read().decode("utf-8"))
    except Exception as ex:
        print("Found Error in auth phase:%s" % str(ex))