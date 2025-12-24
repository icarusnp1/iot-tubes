#include <Wire.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <LiquidCrystal_I2C.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <MAX30105.h>  // untuk MAX30102/30105
#include <MPU6500_WE.h>
#include <ArduinoJson.h>

// ================== WIFI CONFIG ==================
const char* ssid = "Kirby";
const char* password = "";

// MQTT via TLS
WiFiClientSecure espClient;
PubSubClient client(espClient);

// Ganti broker/user/pass sesuai milikmu
const char* MQTT_BROKER = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud";
const int MQTT_PORT = 8883;
const char* MQTT_USER = "Tubes_iot123";
const char* MQTT_PASS = "Tubes_iot123";
const char* MQTT_CLIENT_ID = "esp32_device_1";
// Topik untuk RAW data (publish) dan STATUS (subscribe)
const char* RAW_TOPIC = "esp32_1/raw-data";
const char* STATUS_TOPIC = "esp32_1/status";
const char* SESSION_TOPIC = "esp32_1/session";

// ================== PIN LED & BUZZER (default) ==================
const int PIN_LED_GREEN = 14;
const int PIN_LED_YELLOW = 12;
const int PIN_LED_RED = 13;
const int PIN_BUZZER = 27;

// ================== PIN & SENSOR CONFIG ==================
#define DHTPIN 4
#define DHTTYPE DHT11
#define MPU6500_ADDR 0x68

DHT dht(DHTPIN, DHTTYPE);
MPU6500_WE mpu = MPU6500_WE(MPU6500_ADDR);
MAX30105 max30102;
LiquidCrystal_I2C lcd(0x27, 16, 2);

// ================== SAMPLING & BATCH CONFIG ==================
int USER_ID = 2;                                 // ganti sesuai user_id di DB
const int SAMPLES_PER_BATCH = 25;                // 25 sampel per batch
const unsigned long SAMPLE_INTERVAL_MS = 40;     // 25 Hz
const unsigned long PUBLISH_INTERVAL_MS = 1000;  // kirim batch tiap 1 detik

long irBuffer[SAMPLES_PER_BATCH];
long redBuffer[SAMPLES_PER_BATCH];
int sampleCount = 0;

unsigned long lastSampleMillis = 0;
unsigned long lastPublishMillis = 0;

// untuk simpan nilai terakhir suhu/humid/accel dalam batch
float lastTemp = 0.0;
float lastHum = 0.0;
xyzFloat lastAccel;

// status terakhir diterima dari backend
String last_status = "unknown";

void controlOutputsByStatus(const String& status) {
  if (status == "normal") {
    digitalWrite(PIN_LED_GREEN, HIGH);
    digitalWrite(PIN_LED_YELLOW, LOW);
    digitalWrite(PIN_LED_RED, LOW);
    // matikan buzzer
    noTone(PIN_BUZZER);
  } else if (status == "warning") {
    digitalWrite(PIN_LED_GREEN, LOW);
    digitalWrite(PIN_LED_YELLOW, HIGH);
    digitalWrite(PIN_LED_RED, LOW);
    noTone(PIN_BUZZER);
  } else if (status == "danger") {
    digitalWrite(PIN_LED_GREEN, LOW);
    digitalWrite(PIN_LED_YELLOW, LOW);
    digitalWrite(PIN_LED_RED, HIGH);
    // bunyikan buzzer terus selama status danger
    tone(PIN_BUZZER, 2000);  // 2kHz, cukup nyaring
  } else {
    // unknown / default
    digitalWrite(PIN_LED_GREEN, LOW);
    digitalWrite(PIN_LED_YELLOW, LOW);
    digitalWrite(PIN_LED_RED, LOW);
    noTone(PIN_BUZZER);
  }
}

// ================== MQTT CALLBACK ==================
void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.println("===========================");
  Serial.println("🚨 CALLBACK TRIGGERED!");
  Serial.println("===========================");

  Serial.println("====== MQTT CALLBACK ======");
  Serial.print("Topic: ");
  Serial.println(topic);

  String jsonStr;
  for (unsigned int i = 0; i < length; i++) {
    jsonStr += (char)payload[i];
  }
  Serial.println("RAW PAYLOAD CHARS:");
  for (unsigned int i = 0; i < length; i++) {
    Serial.print((int)payload[i]);
    Serial.print(" ");
  }
  Serial.println();

  Serial.print("Payload string: ");
  Serial.println(jsonStr);

  // Parse JSON
  StaticJsonDocument<256> doc;
  DeserializationError err = deserializeJson(doc, jsonStr);

  if (err) {
    Serial.print("JSON Parse ERROR: ");
    Serial.println(err.c_str());
    return;
  }

  // ===== ADDED: Handle SESSION_TOPIC =====
  if (strcmp(topic, SESSION_TOPIC) == 0) {

    // Payload is plain integer (e.g. "3"), NOT JSON
    String payloadStr;
    for (unsigned int i = 0; i < length; i++) {
      payloadStr += (char)payload[i];
    }

    payloadStr.trim();  // remove whitespace / newline

    int newUserId = payloadStr.toInt();

    if (newUserId > 0) {
      USER_ID = newUserId;
      Serial.print("[PARSED SESSION user_id] -> ");
      Serial.println(USER_ID);
    } else {
      Serial.print("[ERROR] Invalid SESSION payload: ");
      Serial.println(payloadStr);
    }

    // Do not continue into status parsing
    return;
  }
  // ===== END ADDED =====

  // Ambil status dari JSON
  const char* status = doc["status"];
  if (status) {
    last_status = String(status);
    Serial.print("[PARSED STATUS] -> ");
    Serial.println(last_status);

    controlOutputsByStatus(last_status);
  } else {
    Serial.println("[ERROR] Field \"status\" tidak ditemukan");
  }
  Serial.print("last_status now = ");
  Serial.println(last_status);
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
  espClient.setInsecure();  // development
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(mqttCallback);

  while (!client.connected()) {
    Serial.print("Connecting to MQTT...");
    if (client.connect(MQTT_CLIENT_ID, MQTT_USER, MQTT_PASS)) {
      Serial.println("✅ Connected to HiveMQ Cloud!");
      // subscribe ke status topic
      if (client.subscribe(STATUS_TOPIC)) {
        Serial.print("✅ Subscribed to ");
        Serial.println(STATUS_TOPIC);
      } else {
        Serial.println("❌ Subscribe failed");
      }

      // subscribe ke session topic
      if (client.subscribe(SESSION_TOPIC)) {
        Serial.print("✅ Subscribed to ");
        Serial.println(SESSION_TOPIC);
      } else {
        Serial.println("❌ Subscribe failed");
      }

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

  pinMode(PIN_LED_GREEN, OUTPUT);
  pinMode(PIN_LED_YELLOW, OUTPUT);
  pinMode(PIN_LED_RED, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  digitalWrite(PIN_LED_GREEN, LOW);
  digitalWrite(PIN_LED_YELLOW, LOW);
  digitalWrite(PIN_LED_RED, LOW);
  noTone(PIN_BUZZER);

  // buffer MQTT cukup besar untuk batch JSON
  client.setBufferSize(1024);

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
    while (1)
      ;
  }

  max30102.setup(0x2F, 4, 2, 100, 411, 16384);
  max30102.setPulseAmplitudeRed(0x2F);
  max30102.setPulseAmplitudeIR(0x2F);
  max30102.setPulseAmplitudeGreen(0);

  // Init MPU6500
  if (!mpu.init()) {
    Serial.println("❌ MPU6500 not detected!");
    lcd.setCursor(0, 1);
    lcd.print("MPU ERR!");
    while (1)
      ;
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

  unsigned long now = millis();

  // ========== Sampling berkala ==========
  if (now - lastSampleMillis >= SAMPLE_INTERVAL_MS) {
    lastSampleMillis = now;

    // Baca DHT (kalau error, pakai nilai terakhir)
    float suhu = dht.readTemperature();
    float kelembapan = dht.readHumidity();
    if (!isnan(suhu) && !isnan(kelembapan)) {
      lastTemp = suhu;
      lastHum = kelembapan;
    }

    // Baca MPU6500 (accel)
    lastAccel = mpu.getGValues();

    // Baca MAX3010x (RAW IR & RED)
    long irValue = max30102.getIR();
    long redValue = max30102.getRed();

    if (sampleCount < SAMPLES_PER_BATCH) {
      irBuffer[sampleCount] = irValue;
      redBuffer[sampleCount] = redValue;
      sampleCount++;
    }

    // Debug basic di Serial
    Serial.print("SAMPLE ");
    Serial.print(sampleCount);
    Serial.print(" | IR: ");
    Serial.print(irValue);
    Serial.print(" RED: ");
    Serial.print(redValue);
    Serial.print(" T: ");
    Serial.print(lastTemp);
    Serial.print(" H: ");
    Serial.print(lastHum);
    Serial.print(" Accel z: ");
    Serial.println(lastAccel.z, 3);

    // Tampilkan info singkat di LCD
    lcd.setCursor(0, 0);
    lcd.print("T:");
    lcd.print(lastTemp, 1);
    lcd.print("C H:");
    lcd.print(lastHum, 0);
    lcd.print("%  ");

    lcd.setCursor(0, 1);
    lcd.print("IR:");
    lcd.print(irValue);
    lcd.print("   ");

    Serial.print("[PARSED STATUS] -> ");
    Serial.println(last_status);
  }

  // ========== Publish batch tiap 1 detik ==========
  if ((now - lastPublishMillis >= PUBLISH_INTERVAL_MS) && sampleCount > 0) {
    lastPublishMillis = now;

    // Susun JSON batch
    String payload = "{";
    payload += "\"user_id\":" + String(USER_ID);
    payload += ",\"temp_c\":" + String(lastTemp, 2);
    payload += ",\"humidity\":" + String(lastHum, 2);
    payload += ",\"accel_x\":" + String(lastAccel.x, 4);
    payload += ",\"accel_y\":" + String(lastAccel.y, 4);
    payload += ",\"accel_z\":" + String(lastAccel.z, 4);

    // Array samples
    payload += ",\"samples\":[";
    for (int i = 0; i < sampleCount; i++) {
      payload += "{";
      payload += "\"ir\":" + String(irBuffer[i]);
      payload += ",\"red\":" + String(redBuffer[i]);
      payload += "}";
      if (i < sampleCount - 1) payload += ",";
    }
    payload += "]}";

    size_t len = payload.length();
    if (client.publish(RAW_TOPIC, payload.c_str())) {
      Serial.print("✅ MQTT batch publish OK, len = ");
      Serial.println(len);
      Serial.println(payload);
    } else {
      Serial.print("❌ MQTT batch publish FAILED, len = ");
      Serial.println(len);
    }

    // Reset buffer
    sampleCount = 0;
  }
}
