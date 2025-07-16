#!/bin/bash

echo "=== X11 フォワーディング テスト ==="
echo

echo "1. DISPLAY環境変数の確認:"
echo "DISPLAY = $DISPLAY"
echo

echo "2. X11ソケットの確認:"
if [ -d "/tmp/.X11-unix" ]; then
    echo "✓ /tmp/.X11-unix が存在します"
    ls -la /tmp/.X11-unix/
else
    echo "✗ /tmp/.X11-unix が見つかりません"
fi
echo

echo "3. X11サーバーへの接続テスト:"
if xset q >/dev/null 2>&1; then
    echo "✓ X11サーバーに接続できました"
else
    echo "✗ X11サーバーに接続できません"
    echo "  以下を試してください:"
    echo "  - ホストで 'xhost +local:docker' を実行"
    echo "  - DISPLAY環境変数を確認"
    echo "  - X Serverが起動していることを確認"
fi
echo

echo "4. OpenGL の確認:"
if command -v glxinfo >/dev/null 2>&1; then
    if glxinfo >/dev/null 2>&1; then
        echo "✓ OpenGL が利用可能です"
        glxinfo | grep -E "(OpenGL vendor|OpenGL renderer|direct rendering)"
    else
        echo "✗ OpenGL が利用できません"
    fi
else
    echo "- glxinfo がインストールされていません"
fi
echo

echo "5. 簡単なGUIアプリケーションテスト:"
if command -v xeyes >/dev/null 2>&1; then
    echo "xeyes を起動しています... (Ctrl+C で終了)"
    xeyes &
    XEYES_PID=$!
    sleep 3
    kill $XEYES_PID 2>/dev/null
    echo "✓ xeyes が正常に起動しました"
else
    echo "- xeyes がインストールされていません"
fi

echo
echo "=== テスト完了 ==="
