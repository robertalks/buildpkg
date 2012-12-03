# Update PATH to include @@PREFIX@@/sbin

_UID=$(id -u)

if [ $_UID -eq 0 ]; then
  PATH="@@PREFIX@@/sbin:$PATH"
  export PATH
fi

unset _UID
