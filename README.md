# IoT ESP32 + Application Flutter

Ce projet permet de :
- Lire des capteurs connectés à un ESP32 : **DHT11 (température/humidité)**, **LDR (luminosité)**, **HC-SR04 (distance)**.
- Contrôler des actionneurs : **LED** et **Servo moteur** via MQTT.
- Visualiser les données en temps réel et contrôler les actionneurs depuis une **application mobile Flutter**.

---

## 🔧 Dépôt ESP32
Le code ESP32 et les dépendances Arduino/Wokwi sont disponibles ici :
[https://github.com/joachimbang/iot_arduino_code.git](https://github.com/joachimbang/iot_arduino_code.git)

---

## 📱 Application mobile Flutter
L’application permet :
- Affichage en temps réel des capteurs.
- Contrôle des actionneurs (LED et servo).

Lien GitHub : [https://github.com/joachimbang/iot-app.git](https://github.com/joachimbang/iot-app.git)

---

## 📥 Télécharger uniquement l’APK
Pour Android, vous pouvez télécharger directement l’APK pré-généré :
- Dans le dépôt, dossier `application_build/app-release.apk`.
- Ou via la section **Releases** GitHub pour la dernière version stable.

---

## ⚡ Prérequis pour l’APK Android
- Android 7.0+
- Connexion Wi-Fi (même réseau que l’ESP32)
- Autoriser l’installation depuis des sources inconnues

---

## 📖 Instructions rapides
1. Installer l’APK sur votre smartphone.
2. Ouvrir l’application.
3. Visualiser les données des capteurs en temps réel.
4. Contrôler LED et servo à distance via l’application.

---

## 🔗 Liens utiles
- MQTT broker utilisé : [HiveMQ public broker](https://www.hivemq.com/public-mqtt-broker/)
- Documentation des capteurs : DHT11, HC-SR04, LDR
