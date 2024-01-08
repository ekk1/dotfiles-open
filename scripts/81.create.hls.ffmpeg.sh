rm -rf *.m3u8
rm -rf 1080p
rm -rf 720p
rm -rf 480p
mkdir -p 1080p
mkdir -p 720p
mkdir -p 480p
ffmpeg -i $1 \
    -vf "scale=-2:1080" \
    -c:v libx265 -x265-params "keyint=60:min-keyint=60:scenecut=0" -crf 23 -tag:v hvc1 -preset slow -force_key_frames "expr:gte(t,n_forced*2)" \
    -c:a aac -b:a 192k -ac 2 \
    -f hls \
    -hls_time 2 \
    -hls_playlist_type vod \
    -hls_flags independent_segments \
    -hls_segment_type mpegts \
    -hls_base_url "1080p/" \
    -hls_segment_filename "1080p/data%02d.ts" \
    stream_1080p.m3u8

ffmpeg -i $1 \
    -vf "scale=-2:720" \
    -c:v libx265 -x265-params "keyint=60:min-keyint=60:scenecut=0" -crf 28 -tag:v hvc1 -preset slow -force_key_frames "expr:gte(t,n_forced*2)" \
    -c:a aac -b:a 128k -ac 2 \
    -f hls \
    -hls_time 2 \
    -hls_playlist_type vod \
    -hls_flags independent_segments \
    -hls_segment_type mpegts \
    -hls_base_url "720p/" \
    -hls_segment_filename "720p/data%02d.ts" \
    stream_720p.m3u8

ffmpeg -i $1 \
    -vf "scale=-2:480" \
    -c:v libx265 -x265-params "keyint=60:min-keyint=60:scenecut=0" -crf 28 -tag:v hvc1 -preset slow -force_key_frames "expr:gte(t,n_forced*2)" \
    -c:a aac -b:a 96k -ac 2 \
    -f hls \
    -hls_time 2 \
    -hls_playlist_type vod \
    -hls_flags independent_segments \
    -hls_segment_type mpegts \
    -hls_base_url "480p/" \
    -hls_segment_filename "480p/data%02d.ts" \
    stream_480p.m3u8

# Geneate a master m3u8 if needed
