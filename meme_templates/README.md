# Meme Templates

This folder contains images of meme templates and instructions on how to use them.

## Developer Notes

### Prerequisites

We need to have `ffmpeg`, `imagemick` and `ollama` installed.

1. FFMPEG

```sh
brew install ffmpeg
```

2. Imagemick

```sh
brew install imagemagick
```

3. Ollama

```sh
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5vl:7b
```

### Rename files

First we need to rename any existing files not following our naming conventions. This is also useful when adding new meme templates to this folder.

```sh
chmod +x rename_files.sh
./rename_files.sh
```

### Convert files

There is a script that currently when run converts all image files to .jpg.

```sh
chmod +x convert_to_jpg.sh
./convert_to_jpg.sh
```

### Generate resized images

There is a script that resizes all images in two sizes for Supabase storage buckets:

- `meme_templates`: max `153600` bytes
- `meme_templates_low`: max `20480` bytes

If an image cannot be reduced under those exact limits, the script exits with an error and does not keep an oversized output.

```sh
chmod +x generate_resized_images.sh
./generate_resized_images.sh        # all numeric files, ascending
./generate_resized_images.sh 8      # only file number 8
./generate_resized_images.sh 8 20   # range 8..20 (inclusive), ascending
```

### Generate tags

There is a script that send the images one by one to Ollama for generating a list of separated tags we can use in the database. We can run the script by specifying a flavor and a starting/ending point.

```sh
ollama serve
chmod +x generate_tags.sh
./generate_tags.sh development 1 50
```

### Upload to Supabase

We can then upload the images to Supabase by additionally providing a flavor.

```sh
chmod +x upload_templates_by_flavor.sh
./upload_templates_by_flavor.sh development # development
./upload_templates_by_flavor.sh staging     # staging
./upload_templates_by_flavor.sh production  # production
```
