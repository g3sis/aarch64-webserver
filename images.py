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

         # ASCII art for the h1 (preserve backslashes using a raw string)
         ascii_art = r"""    _             <a href="/" style="color:pink;text-decoration:none;">_<a>     _           
   / \   _ __ ___| |__ (_)_   _____ 
  / _ \ | '__/ __| '_ \| \ \ / / _ \
 / ___ \| | | (__| | | | |\ V /  __/
/_/   \_\_|  \___|_| |_|_| \_/ \___|"""

         # Build HTML content: include the requested h1 styling and ASCII art as the h1 content
         html_content = (
         "<!DOCTYPE html>\n"
         "<html>\n"
         "<head>\n"
         "    <meta charset=\"utf-8\">\n"
         "    <style>\n"
         "        /* layout: stack header and gallery vertically */\n"
         "        body { display: flex; flex-direction: column; align-items: center; margin: 0; padding: 0; }\n"
         "        /* h1: preserve spaces, monospace font for alignment, centered */\n"
         "        h1 {\n"
         "            font-family: \"Courier New\", Courier, monospace; /* Essential for alignment */\n"
         "            white-space: pre; /* Essential to preserve spaces */\n"
         "            font-size: 14px;  /* Adjusted size for shorter art */\n"
         "            line-height: 1.2;\n"
         "            text-align: center;\n"
         "            margin: 8px 0; /* small vertical spacing */\n"
         "            width: 100%;\n"
         "        }\n"
         "        /* gallery holds the images, centered and wrapped */\n"
         "        .gallery { display: flex; flex-wrap: wrap; justify-content: center; gap: 0px; width: 100%; box-sizing: border-box; padding: 8px 0; }\n"
         "        .gallery img { width: 10%; height: auto; display: block; }\n"
         "        @media (max-width: 600px) {\n"
         "            .gallery img { width: 30%; }\n"
         "        }\n"
         "    </style>\n"
         "</head>\n"
         "<body>\n"
         "    <h1>\n"
         f"{ascii_art}\n"
         "    </h1>\n"
         "    <div class=\"gallery\">\n"
         "    " + ("\n    ".join(img_tags)) + "\n"
         "    </div>\n"
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

         with open("sites/images.html", "wb") as f:
             f.write(header + body_bytes)
         print(f"Created images.html ({len(header + body_bytes)} bytes)")

         # Update index.html header
         index_path = Path("sites/index.html")
         if index_path.exists():
             print("Updating index.html header...")
             with open(index_path, 'rb') as f:
                 content = f.read()

             if b'\n\n' in content:
                 _, body = content.split(b'\n\n', 1)

                 new_header = (
                     f"HTTP/1.1 200 OK\n"
                     f"Content-Length: {len(body)}\n"
                     f"Content-Type: text/html\n"
                     f"\n"
                 ).encode('ascii')

                 with open(index_path, 'wb') as f:
                     f.write(new_header + body)
                 print(f"Updated index.html (Content-Length: {len(body)})")

         # Update wizard.html header
         wizard_path = Path("sites/wizard.html")
         if wizard_path.exists():
             print("Updating wizard.html header...")
             with open(wizard_path, 'rb') as f:
                 content = f.read()

             if b'\n\n' in content:
                 _, body = content.split(b'\n\n', 1)

                 new_header = (
                     f"HTTP/1.1 200 OK\n"
                     f"Content-Length: {len(body)}\n"
                     f"Content-Type: text/html\n"
                     f"\n"
                 ).encode('ascii')

                 with open(wizard_path, 'wb') as f:
                     f.write(new_header + body)
                 print(f"Updated wizard.html (Content-Length: {len(body)})")

         # Update books.html header
         books_path = Path("sites/books.html")
         if wizard_path.exists():
             print("Updating books.html header...")
             with open(books_path, 'rb') as f:
                 content = f.read()

             if b'\n\n' in content:
                 _, body = content.split(b'\n\n', 1)

                 new_header = (
                     f"HTTP/1.1 200 OK\n"
                     f"Content-Length: {len(body)}\n"
                     f"Content-Type: text/html\n"
                     f"\n"
                 ).encode('ascii')

                 with open(books_path, 'wb') as f:
                     f.write(new_header + body)
                 print(f"Updated books.html (Content-Length: {len(body)})")

if __name__ == "__main__":
         create_http_response_files()
