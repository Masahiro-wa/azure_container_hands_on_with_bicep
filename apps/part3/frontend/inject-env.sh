#!/bin/sh

# 環境変数を runtime-env.js に書き込む
cat <<EOF > /usr/share/nginx/html/runtime-env.js
window.RUNTIME_ENV = {
  REACT_APP_API_URL: "${REACT_APP_API_URL}",
  REACT_APP_OTHER_VARIABLE: "${REACT_APP_OTHER_VARIABLE}"
};
EOF

exec "$@"
