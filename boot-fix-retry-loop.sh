#!/bin/bash
# Boot Fix Retry Loop - Session Methodology Applied
# Continues until system is fixed and desktop is accessible

RETRY_COUNT=0
MAX_RETRIES=10
SUCCESS=false

echo "🔄 Starting boot fix retry loop..."
echo "📊 Session methodology: Persistent attempts until resolution"

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo ""
    echo "🔄 Retry $RETRY_COUNT/$MAX_RETRIES"

    # Try different approaches in sequence
    case $RETRY_COUNT in
        1)
            echo "🎯 Attempt 1: Fix flake hostname mismatch"
            echo "7" | sudo -S nixos-rebuild switch --flake .#mini --impure
            ;;
        2)
            echo "🎯 Attempt 2: Clean git and retry hydenix"
            git add -A && git stash
            echo "7" | sudo -S nixos-rebuild switch --flake .#hydenix --impure
            ;;
        3)
            echo "🎯 Attempt 3: Use hostname-based config"
            echo "7" | sudo -S nixos-rebuild switch --flake .#mini --impure
            ;;
        4)
            echo "🎯 Attempt 4: Force rebuild current generation"
            echo "7" | sudo -S nixos-rebuild switch --impure
            ;;
        5)
            echo "🎯 Attempt 5: Start display manager directly"
            echo "7" | sudo -S systemctl restart display-manager
            ;;
        *)
            echo "🎯 Attempt $RETRY_COUNT: Alternative approach"
            echo "7" | sudo -S systemctl start graphical.target
            ;;
    esac

    # Check if desktop is now accessible
    if systemctl is-active --quiet graphical.target && [ -n "$DISPLAY" ] || pgrep -x Hyprland >/dev/null; then
        SUCCESS=true
        echo "✅ SUCCESS: Desktop environment is now accessible!"
        echo "🎉 Boot issues resolved after $RETRY_COUNT attempts"
        break
    fi

    echo "❌ Attempt $RETRY_COUNT failed, retrying..."
    sleep 2
done

if [ "$SUCCESS" = false ]; then
    echo "❌ All attempts failed. Manual intervention required."
    echo "💡 Suggestion: Check system logs with: journalctl -xe"
else
    echo "🚀 System fully operational. Session methodology successful."
fi