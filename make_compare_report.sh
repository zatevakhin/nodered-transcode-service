#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <video1> <video2>"
    exit 1
fi

VIDEO1="$1"
VIDEO2="$2"
REPORT_FILE="video_comparison_report.txt"

# Function to get video information
get_video_info() {
    ffmpeg -i "$1" 2>&1 | grep -E 'Stream|Duration'
}

# Function to calculate PSNR and SSIM metrics
calculate_quality_metrics() {
    ffmpeg -i "$1" -i "$2" -filter_complex "[0:v][1:v]psnr=stats_file=psnr.log[out];[0:v][1:v]ssim=stats_file=ssim.log" -map "[out]" -f null -
}

# Function to get bitrate information
get_bitrate() {
    ffprobe -v quiet -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$1"
}

echo "Video Quality Comparison Report" > "$REPORT_FILE"
echo "=========================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Compare basic information
echo "Video 1 Information:" >> "$REPORT_FILE"
get_video_info "$VIDEO1" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Video 2 Information:" >> "$REPORT_FILE"
get_video_info "$VIDEO2" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Compare bitrates
BITRATE1=$(get_bitrate "$VIDEO1")
BITRATE2=$(get_bitrate "$VIDEO2")
echo "Bitrate Comparison:" >> "$REPORT_FILE"
echo "Video 1: $((BITRATE1/1000)) kbps" >> "$REPORT_FILE"
echo "Video 2: $((BITRATE2/1000)) kbps" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Calculate and store quality metrics
echo "Calculating PSNR and SSIM metrics..." >> "$REPORT_FILE"
calculate_quality_metrics "$VIDEO1" "$VIDEO2" 2>> "$REPORT_FILE"

# Extract average PSNR from log
if [ -f "psnr.log" ]; then
    echo "" >> "$REPORT_FILE"
    echo "PSNR Results:" >> "$REPORT_FILE"
    tail -n 1 psnr.log >> "$REPORT_FILE"
fi

# Extract average SSIM from log
if [ -f "ssim.log" ]; then
    echo "" >> "$REPORT_FILE"
    echo "SSIM Results:" >> "$REPORT_FILE"
    tail -n 1 ssim.log >> "$REPORT_FILE"
fi

echo "Comparison complete! Results saved in $REPORT_FILE"

