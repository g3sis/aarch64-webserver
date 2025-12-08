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
                 f"HTTP/1.1 200 OK\r\n"
                 f"Content-Type: {mime_type}\r\n"
                 f"Content-Encoding: gzip\r\n"
                 f"Content-Length: {len(compressed_data)}\r\n"
                 f"Cache-Control: max-age=3600\r\n"
                 f"\r\n"
             ).encode('ascii')

             # Combine header + compressed data
             response_data = http_header + compressed_data

             # Write to output file
             output_filename = f"{img_path.stem}.http"
             output_path = output_dir / output_filename

             with open(output_path, 'wb') as f:
                 f.write(response_data)

             print(f"Created {output_path} ({len(response_data)} bytes)")

if __name__ == "__main__":
         create_http_response_files()
