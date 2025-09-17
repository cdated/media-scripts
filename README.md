# Plex Media Scripts

A collection of bash scripts for managing Plex media.

## Scripts

### `fix_permissions.sh`

Fixes file ownership and permissions for Plex media.

**Features:**

- Sets ownership to `cdated:media` for all files and directories

**Usage:**

```bash
sudo ./fix_permissions.sh
```

**Requirements:**

- Must be run with sudo/root privileges
- User `cdated` and group `media` must exist on the system

### `remove_pillarboxes.sh`

Removes pillarboxes from video files and converts them to 4:3 aspect
ratio, specifically designed for content like Columbo episodes that were
originally filmed in 4:3 but distributed in 16:9 with black bars.

**Features:**

- Crops 1920x1080 (16:9) videos to 1440x1080 (4:3) by removing 240
  pixels from each side
- GPU acceleration support using AMD VAAPI when available
- Automatic fallback to software encoding if GPU acceleration fails
- Preserves original files - creates converted versions in
  `Converted_4x3/` directory
- Validates video dimensions before processing

**Usage:**

```bash
./remove_pillarboxes.sh
```

**Requirements:**

- `ffmpeg` with VAAPI support (for GPU acceleration)
- `ffprobe` for video analysis
- AMD GPU with VAAPI support (optional, falls back to software encoding)

**Output:**

- Converted files are saved in `Converted_4x3/` directory
- Original directory structure is preserved
- Files are renamed with `_4x3` suffix
