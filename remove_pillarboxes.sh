#!/bin/bash

# Script to remove pillarboxes from Columbo episodes and convert to 4:3 ratio
# This crops the video from 1920x1080 (16:9) to 1440x1080 (4:3) by removing 240 pixels from each side
# Uses GPU acceleration (AMD VAAPI) when available for faster processing

# Create output directory
mkdir -p "Converted_4x3"

# Function to process a single file
process_file() {
    local input_file="$1"
    local relative_path="${input_file#./}"
    local output_dir="Converted_4x3/$(dirname "$relative_path")"
    local filename=$(basename "$input_file")
    local output_file="$output_dir/${filename%.*}_4x3.${filename##*.}"

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    echo "Processing: $input_file"
    echo "Output: $output_file"

    # Check video width using ffprobe
    video_width=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$input_file" 2>/dev/null)

    if [ "$video_width" != "1920" ]; then
        echo "⚠ Skipping: Video width is $video_width pixels, not 1920. Cannot apply pillarbox removal."
        echo "---"
        return
    fi

    echo "✓ Video width confirmed: 1920 pixels"

    local success=false
    local use_gpu=true

    if [ "$use_gpu" = "true" ]; then
        echo "Using GPU acceleration (vaapi)"

        # VAAPI encoding
        ffmpeg \
            -y -nostdin -hide_banner -loglevel error \
            -vaapi_device /dev/dri/renderD128 \
            -hwaccel vaapi \
            -hwaccel_output_format vaapi \
            -i "$input_file" \
            -c:v h264_vaapi \
            -preset medium \
            -crf 23 \
            -c:a copy \
            -c:s copy \
            -map 0 \
            -vf "crop=1440:1080:240:0,scale_vaapi=640:480" \
            "$output_file"

        if [ $? -eq 0 ]; then
            success=true
            echo "✓ GPU encoding successful"
        else
            echo "⚠ GPU encoding failed, falling back to software encoding"
        fi
    fi

    # Fallback to software encoding if GPU failed or not available
    if [ "$success" = "false" ]; then
        echo "Using software encoding"
        ffmpeg -y -nostdin -hide_banner -loglevel error \
            -i "$input_file" \
            -vf "crop=1440:1080:240:0" \
            -c:v libx264 \
            -preset medium \
            -crf 23 \
            -c:a copy \
            -c:s copy \
            -map 0 \
            "$output_file"

        if [ $? -eq 0 ]; then
            success=true
        fi
    fi

    if [ "$success" = "true" ]; then
        echo "✓ Successfully processed: $filename"
    else
        echo "✗ Failed to process: $filename"
    fi
    echo "---"
}

echo ""
echo "Starting video processing..."
echo ""

# Find and process all video files
find . -type f \( \
    -iname "*.mp4" -o \
    -iname "*.mkv" -o \
    -iname "*.avi" -o \
    -iname "*.mov" -o \
    -iname "*.m4v" \
    \) -not -path "./Converted_4x3/*" -print0 |
    while IFS= read -r -d '' file; do
        echo $file
        process_file "$file"
    done

echo "All files processed!"
echo "Original files are preserved. Converted files are in the 'Converted_4x3' directory."
