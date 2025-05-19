from flask import Flask
import socket

app = Flask(__name__)

def get_ip_address():
    try:
        # Open a dummy socket connection to get the container's IP address
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))  # Google's DNS, doesn't actually send data
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception as e:
        return f"Error getting IP: {e}"

@app.route('/service')
def hello():
  ip_address = get_ip_address()
  return (f'Hello from {ip_address}!! The app was accessed via HTTP from the ALB to the backend task\n')

if __name__ == "__main__":
  app.run(host='0.0.0.0', port=8080, debug=True)
