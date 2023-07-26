#! /bin/bash

function check_if_directory_exists() {
  dir=$1
  retval=0

  if [ -d "$dir" ]; then
    retval=1
  fi

  return "$retval"
}

function mimetype_contains() {
  file_mimetype=$1
  declare -a mimetypes=("${!2}")

  for mimetype in "${mimetypes[@]}"; do
    if [[ "${file_mimetype}" == *"${mimetype}"* ]]; then
      echo "1"
      return
    fi
  done

  echo "0"
}

function move_file() {
  root_dir=$1
  file_path=$2
  dest_dir_path=$3

  mv "$file_path" "$dest_dir_path"
}

# Category folder names
images_folder_name="Pictures"
audios_folder_name="Musics & Audios"
videos_folder_name="Videos"
documents_folder_name="Documents"
compresseds_folder_name="Compressed Files"
programs_folder_name="Programs"
others_folder_name="Others"

# Mimetypes
forbidden_file_mimetypes=("inode")
image_mimetypes=("image")
audio_mimetypes=("audio")
video_mimetypes=("video")
document_mimetypes=(
  "application/x-pdf"
  "application/pdf"
  "application/msword"
  "application/vnd.lotus-wordpro"
  "application/vnd.ms-word.template.macroenabled.12"
  "application/vnd.ms-word.document.macroenabled.12"
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
  "application/vnd.ms-excel"
  "application/vnd.ms-excel.template.macroenabled.12"
  "application/vnd.ms-excel.sheet.macroenabled.12"
  "application/vnd.ms-excel.sheet.binary.macroenabled.12"
  "application/vnd.ms-excel.addin.macroenabled.12"
  "application/vnd.ms-powerpoint"
  "application/vnd.ms-powerpoint.addin.macroenabled.12"
  "application/vnd.ms-powerpoint.presentation.macroenabled.12"
  "application/vnd.ms-powerpoint.slide.macroenabled.12"
  "application/vnd.ms-powerpoint.template.macroenabled.12"
  "application/vnd.ms-powerpoint.slideshow.macroenabled.12"
  "application/epub+zip"
  "application/vnd.amazon.ebook"
)
compressed_mimetypes=(
  "application/x-tar"
  "application/x-compressed"
  "application/x-zip-compressed"
  "application/zip"
  "multipart/x-zip"
  "application/vnd.rar"
  "application/x-rar-compressed"
  "application/gnutar"
  "application/x-gzip"
  "multipart/x-gzip"
)
program_mimetypes=(
  "application/vnd.debian.binary-package"
  "application/octet-stream"
  "application/mac-binary"
  "application/macbinary"
  "application/x-binary"
  "application/x-macbinary"
  "application/x-debian-package"
  "application/x-msdownload"
  "application/vnd.android.package-archive"
  "application/x-rpm"
)

declare category_dirs=(
  "${images_folder_name}"
  "${audios_folder_name}"
  "${documents_folder_name}"
  "${videos_folder_name}"
  "${compresseds_folder_name}"
  "${programs_folder_name}"
  "${others_folder_name}"
)

# Getting root directory
root_directory=$1

# Check if the directory exists or not
check_if_directory_exists "$root_directory"
root_dir_exists=$?

if [ "$root_dir_exists" == 0 ]; then
  echo "Directory \"$root_directory\" does not exists."
  exit 1
fi

# Change directory to the root directory
cd "$root_directory"

# Create the category folders if they are not exists
for dir in "${category_dirs[@]}"; do
  check_if_directory_exists "$dir"
  retval=$?

  if [ "$retval" == 0 ]; then
    mkdir "$dir"
  fi
done

echo "Moving files into their correct directory..."

for file in "$root_directory"/*; do
  file_mimetype=$(file --mime-type -b "$file")

  if [[ $(mimetype_contains "$file_mimetype" forbidden_file_mimetypes[@]) == "1" ]]; then
    continue
  fi

  if [[ $(mimetype_contains "$file_mimetype" image_mimetypes[@]) == "1" ]]; then
    move_file "$root_directory" "$file" "$images_folder_name"
    continue
  fi

  if [[ $(mimetype_contains "$file_mimetype" video_mimetypes[@]) == "1" ]]; then
    move_file "$root_directory" "$file" "$videos_folder_name"
    continue
  fi

  if [[ $(mimetype_contains "$file_mimetype" audio_mimetypes[@]) == "1" ]]; then
    move_file "$root_directory" "$file" "$audios_folder_name"
    continue
  fi

  if [[ $(mimetype_contains "$file_mimetype" document_mimetypes[@]) == "1" ]]; then
    move_file "$root_directory" "$file" "$documents_folder_name"
    continue
  fi

  if [[ $(mimetype_contains "$file_mimetype" compressed_mimetypes[@]) == "1" ]]; then
    move_file "$root_directory" "$file" "$compresseds_folder_name"
    continue
  fi

  if [[ $(mimetype_contains "$file_mimetype" program_mimetypes[@]) == "1" ]]; then
    move_file "$root_directory" "$file" "$programs_folder_name"
    continue
  fi

  move_file "$root_directory" "$file" "$others_folder_name"

done

echo "Every file has been moved to its correct directory !"
exit 0
