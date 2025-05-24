#!/bin/bash

# Configurables
BATCH_SIZE=10
TEMP_FILE="tmp_hashes.txt"

# Colores personalizados
redColour="\e[0;31m"
greenColour="\e[0;32m"
yellowColour="\e[0;33m"
blueColour="\e[0;34m"
purpleColour="\e[0;35m"
turquoiseColour="\e[0;36m"
grayColour="\e[0;37m"
endColour="\e[0m"

# Mostrar ayuda
usage() {
  echo -e "${grayColour}Uso: ${redColour}$0 ${yellowColour}<archivo_hashes> <api_key>${endColour}"
  echo -e ""
  echo -e "${grayColour}Opciones:${endColour}"
  echo -e "${yellowColour}  -h, --help${purpleColour}           Muestra esta ayuda.${endColour}"
  echo -e ""
  echo -e "${grayColour}Parámetros requeridos:${endColour}"
  echo -e "${yellowColour}  archivo_hashes${purpleColour}       Archivo con hashes a enviar en bloques de 10.${endColour}      Ej: unique_hashes.txt"
  echo -e "${yellowColour}  api_key${purpleColour}              Tu API key de OnlineHashCrack.${endColour}                     Ej: sk_xxxxxxxxxxxxxxxxxxxxxxxx"
  echo -e ""
  echo -e "${grayColour}Ejemplo:${endColour}"
  echo -e "${turquoiseColour}  $0 unique_hashes.txt sk_xxxxxxxxxxxxxxxxxxxxxxxx${endColour}"
  exit 1
}

# Validar argumentos y mostrar ayuda si corresponde
if [ $# -ne 2 ] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
fi

HASH_FILE="$1"
API_KEY="$2"
API_URL="https://api.onlinehashcrack.com/v2"

# Validar existencia del archivo
if [ ! -f "$HASH_FILE" ]; then
  echo -e "${redColour}❌ Archivo '$HASH_FILE' no encontrado.${endColour}"
  exit 1
fi

send_batch() {
  local batch=("$@")
  local json_hashes
  json_hashes=$(printf '"%s",' "${batch[@]}" | sed 's/,$//')

  payload=$(cat <<EOF
{
  "api_key": "$API_KEY",
  "agree_terms": "yes",
  "algo_mode": 22000,
  "hashes": [$json_hashes]
}
EOF
)

  response=$(curl -s -o /tmp/response.txt -w "%{http_code}" -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "$payload")

  echo -e "${blueColour}    ↳ Código HTTP: $response${endColour}"

  if [ "$response" == "429" ]; then
    echo -e "${yellowColour}    ⌛ Límite alcanzado. Durmiendo 1 hora...${endColour}"
    sleep 3600
    return 1
  fi

  success=$(jq -r '.success' /tmp/response.txt)
  message=$(jq -r '.message' /tmp/response.txt)

  if [ "$success" == "true" ]; then
    echo -e "${greenColour}    ✅ $message${endColour}"
  else
    echo -e "${redColour}    ❌ $message${endColour}"
  fi

  return 0
}

main() {
  while true; do
    if [ ! -s "$HASH_FILE" ]; then
      echo -e "${greenColour}🎉 No hay más hashes que procesar. Fin.${endColour}"
      break
    fi

    mapfile -t batch < <(head -n "$BATCH_SIZE" "$HASH_FILE")

    if [ ${#batch[@]} -eq 0 ]; then
      echo -e "${yellowColour}⚠️  No quedan suficientes hashes para procesar un lote.${endColour}"
      break
    fi

    echo -e "${grayColour}📤 Enviando ${#batch[@]} hashes al API...${endColour}"

    send_batch "${batch[@]}"
    if [ $? -eq 0 ]; then
      tail -n +$(($BATCH_SIZE + 1)) "$HASH_FILE" > "$TEMP_FILE"
      mv "$TEMP_FILE" "$HASH_FILE"
      echo -e "${grayColour}    🗑️  Lote procesado y eliminado del archivo.${endColour}"
    else
      echo -e "${yellowColour}    ⏳ Esperando para reintentar...${endColour}"
      continue
    fi

    sleep 2
  done
}

main
