#!/usr/bin/env python3
import os
import gzip
import mimetypes
from pathlib import Path

def create_http_response_files():
         images_dir = Path("images")
         output_dir = Path("images")

         # Get all image files
         image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'}
         image_files = [f for f in images_dir.iterdir()
                        if f.suffix.lower() in image_extensions]

         for img_path in image_files:
             print(f"Processing {img_path}...")

             # Read and gzip the image
             with open(img_path, 'rb') as f:
                 original_data = f.read()

             compressed_data = gzip.compress(original_data)

             # Get MIME type
             mime_type, _ = mimetypes.guess_type(str(img_path))
             if not mime_type:
                 mime_type = "application/octet-stream"

             # Create HTTP response
             http_header = (
                 f"HTTP/1.1 200 OK\n"
                 f"Content-Type: {mime_type}\n"
                 f"Content-Encoding: gzip\n"
                 f"Content-Length: {len(compressed_data)}\n"
                 f"Cache-Control: max-age=3600\n"
                 f"\n"
             ).encode('ascii')

             # Combine header + compressed data
             response_data = http_header + compressed_data

             # Write to output file
             output_filename = f"{img_path.stem}"
             output_path = output_dir / output_filename

             with open(output_path, 'wb') as f:
                 f.write(response_data)

             print(f"Created {output_path} ({len(response_data)} bytes)")

         # Generate images.html
         print("Generating images.html...")
         img_tags = []
         for img_path in sorted(image_files):
             img_tags.append(f'<img src="images/{img_path.name}">')

         html_content = (
             "<!DOCTYPE html>\n"
             "<html>\n"
             "<head>\n"
             "    <style>\n"
             "        body { display: flex; flex-wrap: wrap; margin: 0; padding: 0; }\n"
             "        img { width: 10%; height: auto; display: block; }\n"
             "    </style>\n"
             "</head>\n"
             "<body>\n"
             f"    {''.join(img_tags)}\n"
             "</body>\n"
             "</html>"
         )

         body_bytes = html_content.encode('utf-8')

         header = (
             f"HTTP/1.1 200 OK\n"
             f"Content-Type: text/html\n"
             f"Content-Length: {len(body_bytes)}\n"
             f"\n"
         ).encode('ascii')

         with open("images.html", "wb") as f:
             f.write(header + body_bytes)
         print(f"Created images.html ({len(header + body_bytes)} bytes)")

if __name__ == "__main__":
         create_http_response_files()
