# jwt.sh

An example of how to generate JWT token for use with the GCP API based on the service account details

Token is generated following the formula

 ```{Base64url encoded header}.{Base64url encoded claim set}.{Base64url encoded signature of the header and claim set}```

Base64url is a variant of Base64 that looses padding = and uses the characters - and _ instead of + and /

The generated token can then be used to retrieve the access token

```
POST https://oauth2.googleapis.com/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded

grant_type={{grantType}}&scope={{scope}}&assertion={{jwt}}
```

where
- grantType: urn:ietf:params:oauth:grant-type:jwt-bearer
- scope: same scope passed to the script
- jwt: output of the script
