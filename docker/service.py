from flask import Flask
import socket

app = Flask(__name__)

@app.route('/service')
def hello():
  hostname = socket.gethostname()
  ip_address = socket.gethostbyname(hostname)
  return (f'Hello from {ip_address}!! You have reached behind envoy proxy!\n')

if __name__ == "__main__":
  app.run(host='0.0.0.0', port=8080, debug=True)
