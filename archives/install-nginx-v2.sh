if [ -f /etc/redhat-release ]; then
  myversion=$(awk '{print $3}' /etc/redhat-release | awk -F'.' '{print $1}')
  if [ "$myversion" -eq 6] then


if [ -f /etc/debian_version ]; then
