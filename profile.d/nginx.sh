# Update PATH to include @@PREFIX@@/bin and @@PREFIX@@/sbin

_UID=$(id -u)
PATH="@@PREFIX@@/bin:$PATH"

if [ $_UID -eq 0 ]; then
  PATH="@@PREFIX@@/sbin:$PATH"
fi

unset _UID
export PATH
