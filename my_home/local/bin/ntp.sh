date -s "$(curl -sD - google.com | grep '^Date:' | tr -d '\r,' | awk '{print $2, $4, $3, $6, $7, $5}')"
