#!/bin/bash
set -e

# Compile agent-runner TypeScript
cd /app && npx tsc --outDir /tmp/dist 2>&1 >&2
ln -s /app/node_modules /tmp/dist/node_modules
chmod -R a-w /tmp/dist

# Set up GitHub CLI git credentials if token is available
if [ -n "$GH_TOKEN" ]; then
  gh auth setup-git 2>/dev/null
fi

# Symlink dotfile mounts from /workspace/extra/ into ~/
# (e.g. /workspace/extra/.clypfeed -> ~/.clypfeed)
for d in /workspace/extra/.*; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  [ "$name" = "." ] || [ "$name" = ".." ] && continue
  ln -sfn "$d" "$HOME/$name"
done

# Read container input from stdin, then run
cat > /tmp/input.json
node /tmp/dist/index.js < /tmp/input.json
