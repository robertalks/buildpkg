# Update PATH to include @@PREFIX@@/sbin and @@PREFIX@@/bin

_UID=$(id -u)
PATH="@@PREFIX@@/bin:$PATH"

if [ $_UID -eq 0 ]; then
  PATH="@@PREFIX@@/sbin:$PATH"
fi

unset _UID
export PATH
