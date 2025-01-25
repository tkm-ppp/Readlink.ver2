

#!/bin/bash
cat <<EOL > Procfile.dev
# database.yml を指定された内容でオーバーライト
web: bin/rails server -b 0.0.0.0 -p 3000
js: yarn build:js --watch
EOL

echo "config/database.yml を指定された内容でオーバーライトしました。"
