# HashCrack22000 🔑

Este script de Bash permite automatizar el envío de hashes tipo WPA (`algo_mode: 22000`) al servicio de **OnlineHashCrack**, en bloques de 10 hashes por petición. Ideal para manejar archivos extensos de hashes y automatizar el proceso con gestión de límite de uso de la API (status 429).

## 🚀 Requisitos

Para obtener este script y los archivos necesarios, puedes clonar este repositorio usando el siguiente comando en tu terminal:

```bash
git clone https://github.com/tuusuario/HashCrackAPI.git
```

### 🛠 Permisos de ejecución

Dale permisos de ejecución al script:

```bash
chmod +x hashCrackAPI.sh
```

### 📦 Dependencias

Este script requiere las siguientes herramientas:

```bash
sudo apt update
sudo apt install curl jq
```

---

## 🧠 Funcionamiento

* Envía hashes del archivo de entrada de 10 en 10 a la API.
* Si recibe un error 429 (límite de peticiones), el script espera una hora antes de continuar (`⌛`).
* Elimina los hashes ya procesados del archivo.
* Muestra mensajes informativos con íconos y colores para facilitar la lectura:

  * ✅ Hashes enviados correctamente.
  * ❌ Hashes rechazados.
  * ⌛ Esperando por límite de uso.

---

## 📌 Uso

```bash
Uso: ./hashCrackAPI.sh <archivo_hashes> <api_key>

Opciones:
  -h, --help               Muestra esta ayuda.

Parámetros requeridos:
  archivo_hashes          Archivo con hashes a enviar en bloques de 10.        Ej: unique_hashes.txt
  api_key                 Tu API key de OnlineHashCrack.                      Ej: sk_xxxxxxxxxxxxxxxxxxxxxxxx

Ejemplo:
  ./hashCrackAPI.sh unique_hashes.txt sk_xxxxxxxxxxxxxxxxxxxxxxxx
```
