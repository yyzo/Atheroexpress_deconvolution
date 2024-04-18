#Creates a directory if it does not exist yet.
# createDir() {
#   local dirPath="$1"
#   
#   if [ ! -d "$dirPath" ]; then
#     mkdir -p "$dirPath"
#     echo "Directory created: $dirPath"
#   else
#     echo "Directory already exists: $dirPath"
#   fi
# }
# 

emptyDir() {
  local dirPath="$1"
  local i="$2"
  
  if [ -d "$dirPath" ]; then
    if [ "$(ls -A "$dirPath")" ]; then
      echo "Directory is not empty, clearing contents..."
      rm -r "$dirPath"/*
      echo "Directory emptied ($i): $dirPath"
    else
      echo "$dirPath is empty ($i)"
    fi
  else
    echo "Directory $dirPath not found ($i)"
  fi
}