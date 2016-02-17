# Update PATH to include @@PREFIX@@/bin

_UID="$(id -u 2>/dev/null || echo 1)"
if [ $_UID -eq 0 ]; then
	PATH="@@PREFIX@@/bin:$PATH"
	export PATH
fi

unset _UID
