#include <Wire.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <LiquidCrystal_I2C.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <MAX30105.h>      // MAX30102/30105
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
const int   MQTT_PORT   = 8883;
const char* MQTT_USER   = "Tubes_iot123";
const char* MQTT_PASS   = "Tubes_iot123";
const char* MQTT_CLIENT_ID = "esp32_device_1";

// Topik
const char* RAW_TOPIC     = "esp32_1/raw-data";
const char* STATUS_TOPIC  = "esp32_1/status";
const char* SESSION_TOPIC = "esp32_1/session";

// ================== PIN LED & BUZZER ==================
const int PIN_LED_GREEN  = 14;
const int PIN_LED_YELLOW = 12;
const int PIN_LED_RED    = 13;
const int PIN_BUZZER     = 27;

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
const unsigned long SAMPLE_INTERVAL_MS = 40;     // 25 Hz (20ms=50Hz, 10ms=100Hz)
const unsigned long PUBLISH_INTERVAL_MS = 1000;  // kirim batch tiap 1 detik

// Buffers PPG
long irBuffer[SAMPLES_PER_BATCH];
long redBuffer[SAMPLES_PER_BATCH];

// Buffers ACCEL
float axBuffer[SAMPLES_PER_BATCH];
float ayBuffer[SAMPLES_PER_BATCH];
float azBuffer[SAMPLES_PER_BATCH];

int sampleCount = 0;

unsigned long lastSampleMillis  = 0;
unsigned long lastPublishMillis = 0;

// Timestamp awal batch
unsigned long batchStartMillis = 0;

// Simpan nilai terakhir suhu/humid/accel
float lastTemp = 0.0;
float lastHum  = 0.0;
xyzFloat lastAccel;

// Status terakhir diterima dari backend
String last_status = "unknown";

// ================== IMPORTANT: MOVE BIG BUFFERS OFF STACK ==================
// JSON doc + output buffer dibuat GLOBAL agar loopTask tidak stack overflow
StaticJsonDocument<6144> jsonDoc;
static char mqttOut[7000];

// ================== OUTPUT CONTROL ==================
void controlOutputsByStatus(const String& status) {
  if (status == "normal") {
    digitalWrite(PIN_LED_GREEN, HIGH);
    digitalWrite(PIN_LED_YELLOW, LOW);
    digitalWrite(PIN_LED_RED, LOW);
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
    tone(PIN_BUZZER, 2000);
  } else {
    digitalWrite(PIN_LED_GREEN, LOW);
    digitalWrite(PIN_LED_YELLOW, LOW);
    digitalWrite(PIN_LED_RED, LOW);
    noTone(PIN_BUZZER);
  }
}

// ================== MQTT CALLBACK ==================
void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.println("===========================");
  Serial.println("MQTT CALLBACK");
  Serial.println("===========================");
  Serial.print("Topic: ");
  Serial.println(topic);

  // 1) SESSION_TOPIC: payload integer plain (bukan JSON)
  if (strcmp(topic, SESSION_TOPIC) == 0) {
    String payloadStr;
    payloadStr.reserve(length + 1);
    for (unsigned int i = 0; i < length; i++) payloadStr += (char)payload[i];
    payloadStr.trim();

    int newUserId = payloadStr.toInt();
    if (newUserId > 0) {
      USER_ID = newUserId;
      Serial.print("[SESSION user_id] -> ");
      Serial.println(USER_ID);
    } else {
      Serial.print("[ERROR] Invalid SESSION payload: ");
      Serial.println(payloadStr);
    }
    return;
  }

  // 2) STATUS_TOPIC: JSON
  String jsonStr;
  jsonStr.reserve(length + 1);
  for (unsigned int i = 0; i < length; i++) jsonStr += (char)payload[i];

  StaticJsonDocument<256> doc;
  DeserializationError err = deserializeJson(doc, jsonStr);
  if (err) {
    Serial.print("JSON Parse ERROR: ");
    Serial.println(err.c_str());
    Serial.print("Payload string: ");
    Serial.println(jsonStr);
    return;
  }

  const char* status = doc["status"];
  if (status) {
    last_status = String(status);
    Serial.print("[PARSED STATUS] -> ");
    Serial.println(last_status);
    controlOutputsByStatus(last_status);
  } else {
    Serial.println("[ERROR] Field \"status\" tidak ditemukan");
  }
}

// ================== WIFI & MQTT CONNECT ==================
void connectWiFi() {
  Serial.print("Connecting to WiFi ");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected");
}

void connectMQTT() {
  espClient.setInsecure();  // development only
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(mqttCallback);

  while (!client.connected()) {
    Serial.print("Connecting to MQTT...");
    if (client.connect(MQTT_CLIENT_ID, MQTT_USER, MQTT_PASS)) {
      Serial.println("Connected to HiveMQ Cloud!");

      if (client.subscribe(STATUS_TOPIC)) {
        Serial.print("Subscribed to ");
        Serial.println(STATUS_TOPIC);
      } else {
        Serial.println("Subscribe STATUS failed");
      }

      if (client.subscribe(SESSION_TOPIC)) {
        Serial.print("Subscribed to ");
        Serial.println(SESSION_TOPIC);
      } else {
        Serial.println("Subscribe SESSION failed");
      }

    } else {
      Serial.print("Failed, rc=");
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

  // MQTT buffer harus besar karena payload memuat accel series
  client.setBufferSize(12288); // jika gagal publish, naikkan / kurangi batch

  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Init sensors...");

  dht.begin();

  // Init MAX3010x
  if (!max30102.begin(Wire, I2C_SPEED_STANDARD)) {
    Serial.println("MAX3010x not found!");
    lcd.setCursor(0, 1);
    lcd.print("MAX3010x ERR!");
    while (1) { delay(10); }
  }

  // Setup MAX30102 (sesuaikan jika perlu)
  max30102.setup(0x2F, 4, 2, 100, 411, 16384);
  max30102.setPulseAmplitudeRed(0x2F);
  max30102.setPulseAmplitudeIR(0x2F);
  max30102.setPulseAmplitudeGreen(0);

  // Init MPU6500
  if (!mpu.init()) {
    Serial.println("MPU6500 not detected!");
    lcd.setCursor(0, 1);
    lcd.print("MPU ERR!");
    while (1) { delay(10); }
  }

  // Pastikan sensor diam saat autoOffsets
  mpu.autoOffsets();

  // Konfigurasi gyro (opsional; accel tetap bisa dibaca)
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

    // Set batch start timestamp pada sampel pertama batch
    if (sampleCount == 0) {
      batchStartMillis = now;
    }

    // Baca DHT (kalau error, pakai nilai terakhir)
    float suhu = dht.readTemperature();
    float kelembapan = dht.readHumidity();
    if (!isnan(suhu) && !isnan(kelembapan)) {
      lastTemp = suhu;
      lastHum  = kelembapan;
    }

    // Baca MPU6500 (accel)
    lastAccel = mpu.getGValues();

    // Baca MAX3010x (RAW IR & RED)
    long irValue  = max30102.getIR();
    long redValue = max30102.getRed();

    // Simpan ke buffer
    if (sampleCount < SAMPLES_PER_BATCH) {
      irBuffer[sampleCount]  = irValue;
      redBuffer[sampleCount] = redValue;

      axBuffer[sampleCount] = lastAccel.x;
      ayBuffer[sampleCount] = lastAccel.y;
      azBuffer[sampleCount] = lastAccel.z;

      sampleCount++;
    }

    // Debug Serial
    Serial.print("SAMPLE ");
    Serial.print(sampleCount);
    Serial.print(" | USER ID: ");
    Serial.print(USER_ID);
    Serial.print(" | IR: ");
    Serial.print(irValue);
    Serial.print(" RED: ");
    Serial.print(redValue);
    Serial.print(" T: ");
    Serial.print(lastTemp);
    Serial.print(" H: ");
    Serial.print(lastHum);
    Serial.print(" ax:");
    Serial.print(lastAccel.x, 3);
    Serial.print(" ay:");
    Serial.print(lastAccel.y, 3);
    Serial.print(" az:");
    Serial.println(lastAccel.z, 3);

    // LCD
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

    Serial.print("[STATUS] -> ");
    Serial.println(last_status);
  }

  // ========== Publish batch ==========
  if ((now - lastPublishMillis >= PUBLISH_INTERVAL_MS) && sampleCount > 0) {
    lastPublishMillis = now;

    // Reset doc (karena global)
    jsonDoc.clear();

    jsonDoc["user_id"]   = USER_ID;
    jsonDoc["temp_c"]    = lastTemp;
    jsonDoc["humidity"]  = lastHum;

    // timing metadata
    jsonDoc["t0_ms"] = batchStartMillis;
    jsonDoc["dt_ms"] = SAMPLE_INTERVAL_MS;

    // accel arrays
    JsonArray ax = jsonDoc.createNestedArray("ax");
    JsonArray ay = jsonDoc.createNestedArray("ay");
    JsonArray az = jsonDoc.createNestedArray("az");

    // PPG samples (object array)
    JsonArray samples = jsonDoc.createNestedArray("samples");

    for (int i = 0; i < sampleCount; i++) {
      ax.add(axBuffer[i]);
      ay.add(ayBuffer[i]);
      az.add(azBuffer[i]);

      JsonObject s = samples.createNestedObject();
      s["ir"]  = irBuffer[i];
      s["red"] = redBuffer[i];
    }

    size_t n = serializeJson(jsonDoc, mqttOut, sizeof(mqttOut));
    if (n == 0) {
      Serial.println("❌ serializeJson failed (mqttOut too small?)");
    } else {
      if (client.publish(RAW_TOPIC, mqttOut, n)) {
        Serial.print("✅ MQTT batch publish OK, len = ");
        Serial.println(n);
        // Serial.println(mqttOut); // debug payload jika perlu
      } else {
        Serial.print("❌ MQTT batch publish FAILED, len = ");
        Serial.println(n);
      }
    }

    // Reset batch
    sampleCount = 0;
  }
}
