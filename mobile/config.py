MQTT_BROKER = "mosquitto"      # jika pakai docker-compose; atau "localhost" atau hostname broker
MQTT_PORT = 1883
MQTT_TOPIC = "esp32/+/sensors"  # wildcard: device_id di tempat '+'
MYSQL = {
    "user": "iotuser",
    "password": "iotpass",
    "host": "mysql",
    "port": 3306,
    "db": "iot_health"
}
