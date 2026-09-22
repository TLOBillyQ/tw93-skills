#!/usr/bin/env bash
set -euo pipefail

# 同步上游 tw93/Waza（8 个技能）与 tw93/kami（kami）到本仓库 skills/。
#
# 用法：
#   scripts/sync-upstream.sh                      # 两边都取最新 tag
#   scripts/sync-upstream.sh v3.38.0             # 指定 Waza ref
#   scripts/sync-upstream.sh v3.38.0 V1.16.0     # 两边都指定
#
# 移植是「可重放的机械变换」：skills/ 下与上游逐字一致，Kimi 专属资产
# （kimi.plugin.json、README.md、本脚本）一律不得放进 skills/。
#   - Waza：拷 skills/{check,health,hunt,learn,read,think,ui,write}
#   - kami：拷 plugins/kami/skills/kami；它的 assets/examples/ 是打包期产物，
#     上游 git 里没有，所以同步时保留仓库里已有的那份
# 脚本顺带把 kimi.plugin.json 的 version 对齐 Waza 的 VERSION，并把同步点写进 UPSTREAM。
# 跑完看一眼 git diff 即可提交。

WAZA_URL="https://github.com/tw93/Waza.git"
KAMI_URL="https://github.com/tw93/kami.git"
WAZA_SKILLS="check health hunt learn read think ui write"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WAZA_REF="${1:-}"
KAMI_REF="${2:-}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

default_ref() {
  local ref
  ref="$(git -C "$1" tag --sort=-creatordate | head -1)"
  [ -n "$ref" ] || ref="$(git -C "$1" rev-parse HEAD)"
  printf '%s' "$ref"
}

git clone --quiet "$WAZA_URL" "$TMP/waza"
git clone --quiet "$KAMI_URL" "$TMP/kami"

[ -n "$WAZA_REF" ] || WAZA_REF="$(default_ref "$TMP/waza")"
[ -n "$KAMI_REF" ] || KAMI_REF="$(default_ref "$TMP/kami")"
git -C "$TMP/waza" checkout --quiet "$WAZA_REF"
git -C "$TMP/kami" checkout --quiet "$KAMI_REF"

WAZA_COMMIT="$(git -C "$TMP/waza" rev-parse HEAD)"
KAMI_COMMIT="$(git -C "$TMP/kami" rev-parse HEAD)"
WAZA_VERSION="$(tr -d '\r\n' < "$TMP/waza/VERSION")"

# 上游 git 里没有的打包产物，先留一份再重铺 skills/
KEEP="$TMP/keep"
mkdir -p "$KEEP"
if [ -d "$REPO/skills/kami/assets/examples" ]; then
  cp -R "$REPO/skills/kami/assets/examples" "$KEEP/examples"
fi

rm -rf "$REPO/skills"
mkdir -p "$REPO/skills"
for s in $WAZA_SKILLS; do
  cp -R "$TMP/waza/skills/$s" "$REPO/skills/$s"
done
cp -R "$TMP/kami/plugins/kami/skills/kami" "$REPO/skills/kami"
if [ -d "$KEEP/examples" ] && [ ! -d "$REPO/skills/kami/assets/examples" ]; then
  cp -R "$KEEP/examples" "$REPO/skills/kami/assets/examples"
fi
find "$REPO/skills" -name '.DS_Store' -delete

# core.autocrlf=true 时检出的是 CRLF，统一回 LF，工作树与上游一致
python3 - "$REPO" <<'EOF'
import pathlib, sys
n = 0
for p in pathlib.Path(sys.argv[1]).rglob('*'):
    if not p.is_file():
        continue
    b = p.read_bytes()
    if b'\x00' in b[:8000] or b'\r' not in b:
        continue
    p.write_bytes(b.replace(b'\r\n', b'\n').replace(b'\r', b'\n'))
    n += 1
print(f'normalized {n} files to LF')
EOF

python3 - "$REPO/kimi.plugin.json" "$WAZA_VERSION" <<'EOF'
import json, sys
path, version = sys.argv[1], sys.argv[2]
with open(path, encoding='utf-8') as f:
    manifest = json.load(f)
manifest['version'] = version
with open(path, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)
    f.write('\n')
EOF

printf 'waza %s %s\nkami %s %s\n' "$WAZA_COMMIT" "$WAZA_REF" "$KAMI_COMMIT" "$KAMI_REF" > "$REPO/UPSTREAM"

echo "synced waza $WAZA_REF ($WAZA_COMMIT), kami $KAMI_REF ($KAMI_COMMIT), version $WAZA_VERSION"
echo "review with: git -C '$REPO' diff --stat"
