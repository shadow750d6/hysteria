import signal
import subprocess
import time
import requests
import sys

EXE_PATH = "/media/extern/nonprod/Codes/hysteria/build/hysteria-linux-amd64"
HTTP_PROXY = "http://127.0.0.1:64421"


def run():
    with subprocess.Popen(
        [EXE_PATH, "-l", "debug", "client", "-c", "client_test.yaml"]
    ) as client_process, subprocess.Popen(
        [EXE_PATH, "-l", "debug", "server", "-c", "server_test.yaml"]
    ) as server_process:
        try:
            # Wait for servers to start
            time.sleep(2)

            print("Testing connection to https://www.baidu.com through proxy...")
            proxies = {
                "http": HTTP_PROXY,
                "https": HTTP_PROXY,
            }
            try:
                response = requests.get("https://www.baidu.com", proxies=proxies, timeout=10)
                if response.status_code == 200:
                    print("Connection successful!")
                else:
                    print(f"Connection failed with status code: {response.status_code}")
                    sys.exit(1)
            except requests.exceptions.RequestException as e:
                print(f"Connection failed with exception: {e}")
                sys.exit(1)
        finally:
            client_process.send_signal(signal.SIGINT)
            server_process.send_signal(signal.SIGINT)


if __name__ == "__main__":
    run()
