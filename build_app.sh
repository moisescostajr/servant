#!/bin/zsh
set -e

APP_NAME="Servant"
APP_BUNDLE="$APP_NAME.app"
ICON_SOURCE="/Users/moisescostajr/.gemini/antigravity/brain/01f57571-9d98-4337-876a-771264dabeb7/app_icon_server_fix_1772807892217.png"

echo "🔨 Compilando Dev Server Manager (Versão Release)..."
swift build -c release

echo "📦 Preparando estrutura do macOS App..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Pega o caminho do binario gerado
BIN_PATH=$(swift build -c release --show-bin-path)
cp "$BIN_PATH/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "🎨 Gerando ícones (.icns)..."
if [ -f "$ICON_SOURCE" ]; then
    mkdir -p "AppIcon.iconset"
    sips -z 16 16     "$ICON_SOURCE" --out AppIcon.iconset/icon_16x16.png
    sips -z 32 32     "$ICON_SOURCE" --out AppIcon.iconset/icon_16x16@2x.png
    sips -z 32 32     "$ICON_SOURCE" --out AppIcon.iconset/icon_32x32.png
    sips -z 64 64     "$ICON_SOURCE" --out AppIcon.iconset/icon_32x32@2x.png
    sips -z 128 128   "$ICON_SOURCE" --out AppIcon.iconset/icon_128x128.png
    sips -z 256 256   "$ICON_SOURCE" --out AppIcon.iconset/icon_128x128@2x.png
    sips -z 256 256   "$ICON_SOURCE" --out AppIcon.iconset/icon_256x256.png
    sips -z 512 512   "$ICON_SOURCE" --out AppIcon.iconset/icon_256x256@2x.png
    sips -z 512 512   "$ICON_SOURCE" --out AppIcon.iconset/icon_512x512.png
    sips -z 1024 1024 "$ICON_SOURCE" --out AppIcon.iconset/icon_512x512@2x.png
    
    iconutil -c icns AppIcon.iconset
    mv AppIcon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    rm -rf AppIcon.iconset
else
    echo "⚠️ Aviso: Fonte do ícone não encontrada em $ICON_SOURCE"
fi

echo "📝 Atualizando Info.plist..."
cat <<EOF > "$APP_BUNDLE/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.moisescostajr.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ App Bundle criado com ícone."

echo "💿 Criando uma Imagem de Instalação Distribuível (.dmg)..."
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_BUNDLE" -ov -format UDZO "$APP_NAME.dmg"

echo "✅ Pacote $APP_BUNDLE e $APP_NAME.dmg gerados com sucesso!"
echo "🚀 Para abrir agora mesmo digite: open $APP_BUNDLE"
