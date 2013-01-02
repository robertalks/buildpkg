# Update PATH to include @@PREFIX@@/bin

_UID=$(id -u)
if [ $_UID -eq 0 ]; then
  PATH="@@PREFIX@@/bin:$PATH"
fi

unset _UID
export PATH
