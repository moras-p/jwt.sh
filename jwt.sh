#!/bin/bash

# An example of how to generate JWT token for use with the API based on the service account details (JSONKEY)
# requires jq, base64, and openssl

JSONKEY=$1
SCOPE=$2

if [ -z "$JSONKEY" ] || [ -z "$SCOPE" ]; then
  echo "Usage: jwt.sh <jsonkey> <privkey> <scope>"
  echo "  jsonkey: path to the service account json key file"
  echo "  scope:   space separated list of scopes"
  exit 1
fi

PRIVKEY=$(jq -r '.private_key' $JSONKEY)

function base64url() {
    base64 -w0 | tr '+/' '-_' | tr -d '='
}

function digest() {
    openssl dgst -sha256 -sign <(echo "$PRIVKEY")
}

ALG="RS256"
TYP="JWT"
KID=$(jq -r '.private_key_id' $JSONKEY)
HEADER="{\"alg\":\"$ALG\",\"typ\":\"$TYP\",\"kid\":\"$KID\"}"
HEADER64=$(echo -n $HEADER | base64url)

ISS=$(jq -r '.client_email' $JSONKEY)
AUD=$(jq -r '.token_uri' $JSONKEY)
EXP=$(date -d "+1 hour" +%s)
IAT=$(date +%s)
CLAIMSET="{\"iss\":\"$ISS\",\"scope\":\"$SCOPE\",\"aud\":\"$AUD\",\"exp\":$EXP,\"iat\":$IAT}"
CLAIMSET64=$(echo -n $CLAIMSET | base64url)

SIGNATURE=$(echo -n "$HEADER64.$CLAIMSET64" | digest | base64url)

echo -n $HEADER64.$CLAIMSET64.$SIGNATURE
