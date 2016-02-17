# Update PATH to include @@PREFIX@@/bin and @@PREFIX@@/sbin

_UID="$(id -u 2>/dev/null || echo 1)"
PATH="@@PREFIX@@/bin:$PATH"

if [ $_UID -eq 0 ]; then
	PATH="@@PREFIX@@/sbin:$PATH"
fi

unset _UID
export PATH
