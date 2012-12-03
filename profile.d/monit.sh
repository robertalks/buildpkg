# Update PATH to include @@PREFIX@@/sbin

_UID=$(id -u)

if [ $_UID -eq 0 ]; then
  PATH="@@PREFIX@@/bin:$PATH"
  export PATH
fi

unset _UID
