#Creates a directory if it does not exist yet.
createDir() {
  local dirPath="$1"
  
  if [ ! -d "$dirPath" ]; then
    mkdir -p "$dirPath"
    echo "Directory created: $dirPath"
  else
    echo "Directory already exists: $dirPath"
  fi
}