#include <Wire.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <LiquidCrystal_I2C.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <MAX30105.h>        // dipakai sebagai MAX30102/30105
#include <MPU6500_WE.h>

// ================== WIFI CONFIG ==================
const char* ssid = "Kirby";
const char* password = "";

// MQTT via TLS
WiFiClientSecure espClient;
PubSubClient client(espClient);

// Ganti broker/user/pass sesuai milikmu
const char* MQTT_BROKER   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud";
const int   MQTT_PORT     = 8883;
const char* MQTT_USER     = "Tubes_iot123";
const char* MQTT_PASS     = "Tubes_iot123";
const char* MQTT_CLIENT_ID = "esp32_device_1";

// Topik untuk RAW data (samakan dengan backend)
const char* RAW_TOPIC = "esp32_1/raw-data";

// ================== PIN & SENSOR CONFIG ==================
#define DHTPIN 4
#define DHTTYPE DHT11
#define MPU6500_ADDR 0x68

DHT dht(DHTPIN, DHTTYPE);
MPU6500_WE mpu = MPU6500_WE(MPU6500_ADDR);
MAX30105 max30102;
LiquidCrystal_I2C lcd(0x27, 16, 2);

// ================== MQTT CALLBACK (tidak terlalu dipakai di sini) ==================
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("MQTT [");
  Serial.print(topic);
  Serial.print("]: ");
  for (unsigned int i = 0; i < length; i++) Serial.print((char)payload[i]);
  Serial.println();
}

// ================== WIFI & MQTT CONNECT ==================
void connectWiFi() {
  Serial.print("Connecting to WiFi ");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi Connected");
}

void connectMQTT() {
  espClient.setInsecure();  // untuk HiveMQ Cloud tanpa sertifikat CA (development)
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(callback);

  while (!client.connected()) {
    Serial.print("Connecting to MQTT...");
    if (client.connect(MQTT_CLIENT_ID, MQTT_USER, MQTT_PASS)) {
      Serial.println("✅ Connected to HiveMQ Cloud!");
      // kalau mau subscribe ke topik lain, bisa di sini
      // client.subscribe("test/topic");
    } else {
      Serial.print("❌ Failed, rc=");
      Serial.print(client.state());
      Serial.println(" retrying...");
      delay(1000);
    }
  }
}

// ================== SETUP ==================
void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);

  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Init sensors...");

  dht.begin();

  // Init MAX3010x
  if (!max30102.begin(Wire, I2C_SPEED_STANDARD)) {
    Serial.println("❌ MAX3010x not found!");
    lcd.setCursor(0, 1);
    lcd.print("MAX3010x ERR!");
    while (1);
  }

  // Konfigurasi dasar sensor MAX3010x (tidak hitung BPM/SpO2 di sini)
  max30102.setup(0x1F, 4, 2, 100, 411, 4096);
  max30102.setPulseAmplitudeRed(0x3F);   // LED merah
  max30102.setPulseAmplitudeIR(0x3F);    // LED IR
  max30102.setPulseAmplitudeGreen(0);    // tidak perlu green

  // Init MPU6500
  if (!mpu.init()) {
    Serial.println("❌ MPU6500 not detected!");
    lcd.setCursor(0, 1);
    lcd.print("MPU ERR!");
    while (1);
  }
  mpu.autoOffsets();
  mpu.enableGyrDLPF();
  mpu.setGyrDLPF(MPU6500_DLPF_6);
  mpu.setSampleRateDivider(5);

  connectWiFi();
  connectMQTT();

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Sistem IoT Ready");
  delay(2000);
  lcd.clear();
}

// ================== LOOP ==================
void loop() {
  if (!client.connected()) connectMQTT();
  client.loop();

  // ==== Baca DHT ====
  float suhu = dht.readTemperature();
  float kelembapan = dht.readHumidity();

  if (isnan(suhu) || isnan(kelembapan)) {
    Serial.println("❌ DHT Error!");
    lcd.setCursor(0, 0);
    lcd.print("DHT ERR       ");
    delay(1000);
    return;
  }

  // ==== Baca MPU6500 (accel) ====
  xyzFloat accel = mpu.getGValues();

  // ==== Baca MAX3010x (RAW IR & RED) ====
  long irValue  = max30102.getIR();
  long redValue = max30102.getRed();

  // Tampilkan info singkat di LCD (opsional, hanya debug)
  lcd.setCursor(0, 0);
  lcd.print("T:");
  lcd.print(suhu, 1);
  lcd.print("C H:");
  lcd.print(kelembapan, 0);
  lcd.print("%  ");

  lcd.setCursor(0, 1);
  lcd.print("IR:");
  lcd.print(irValue);
  lcd.print("   ");  // hapus sisa karakter

  // Log di Serial (debug)
  Serial.print("IR: "); Serial.print(irValue);
  Serial.print(" | RED: "); Serial.print(redValue);
  Serial.print(" | Temp: "); Serial.print(suhu);
  Serial.print(" | Hum: "); Serial.print(kelembapan);
  Serial.print(" | Accel: x=");
  Serial.print(accel.x, 3);
  Serial.print(" y=");
  Serial.print(accel.y, 3);
  Serial.print(" z=");
  Serial.println(accel.z, 3);

  // ==== Susun JSON RAW untuk dikirim ke MQTT ====
  // NOTE: ganti user_id sesuai ID user sebenarnya
  int user_id = 2;

  String payload = "{";
  payload += "\"user_id\":" + String(user_id);
  payload += ",\"ir_value\":" + String(irValue);
  payload += ",\"red_value\":" + String(redValue);
  payload += ",\"temp_c\":" + String(suhu, 2);
  payload += ",\"humidity\":" + String(kelembapan, 2);
  payload += ",\"accel_x\":" + String(accel.x, 4);
  payload += ",\"accel_y\":" + String(accel.y, 4);
  payload += ",\"accel_z\":" + String(accel.z, 4);
  payload += "}";

  // Kirim ke MQTT
  if (client.publish(RAW_TOPIC, payload.c_str())) {
    Serial.println("✅ MQTT publish OK: " + payload);
  } else {
    Serial.println("❌ MQTT publish FAILED");
  }

  delay(1000);  // kirim tiap 1 detik (bisa diubah)
}
