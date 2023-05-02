import threading
import paho.mqtt.client as mqtt
import time

class MQTTClient:
    def __init__(self, broker_address: str = 'localhost',
                 broker_port: int = 1883,
                 pub_topic="mqtt/API/response/",
                 sub_topic="mqtt/DEVICE/+"):

        self.client = mqtt.Client()
        self.broker_address = broker_address
        self.broker_port = broker_port
        self.pub_topic = pub_topic
        self.sub_topic = sub_topic
        self.keepAlive = 10000

        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.client.on_disconnect = self.on_disconnect
        self.client = mqtt.Client(client_id="FASTAPI_SERVER")

        self.is_connected = False
        self.reconnect_interval = 5  # seconds

    def on_connect(self, client, userdata, flags, rc):
        print(f"Connected with result code {str(rc)}")
        client.subscribe(self.sub_topic)

    def on_message(self, client, userdata, msg):
        print(f"{msg.topic}: {msg.payload.decode('utf-8')}")

    def on_publish(client, userdata, mid):
        print(f"Message {userdata} published successfully")

    def on_disconnect(self, client, userdata, rc):
        print(f"Disconnected from broker with result code: {str(rc)}. Trying to reconnect in 5 seconds.")
        time.sleep(5)
        self.connect()

    def connect(self):
        while not self.is_connected:
            try:
                self.client.connect(self.broker_address, self.broker_port, self.keepAlive)
                self.client.loop_forever()
            except Exception as e:
                print(f"Error connecting to broker: {e}")
                time.sleep(self.reconnect_interval)

    def publish(self, device_id: str, message):
        self.client.publish(self.pub_topic + device_id + "_RFID", message)

    def start_loop(self):
        t = threading.Thread(target=self.connect)
        t.start()

    def stop_loop(self):
        self.client.loop_stop()
        self.client.disconnect()
        self.is_connected = False
