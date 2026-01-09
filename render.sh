#!/bin/bash
set -e

# Usage: ./render.sh input.md output.pdf
# Example: ./render.sh cv.md cv.pdf

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.md output.pdf"
    echo "Example: $0 cv.md cv.pdf"
    exit 1
fi

INPUT_MD="$1"
OUTPUT_PDF="$2"

if [ ! -f "$INPUT_MD" ]; then
    echo "Error: Input file '$INPUT_MD' not found"
    exit 1
fi

echo "Rendering $INPUT_MD -> $OUTPUT_PDF"

# Get the base name without extension for intermediate files
BASENAME="${OUTPUT_PDF%.pdf}"

# Ensure PATH includes TeX binaries
eval "$(/usr/libexec/path_helper)"

# Generate LaTeX from Markdown
echo "  Step 1/3: Generating LaTeX..."
pandoc "$INPUT_MD" --standalone -o "${BASENAME}.tex"

# Compile PDF (first pass)
echo "  Step 2/3: Compiling PDF (pass 1)..."
pdflatex -interaction=nonstopmode "${BASENAME}.tex" >/dev/null 2>&1

# Compile PDF (second pass for references)
echo "  Step 3/3: Compiling PDF (pass 2)..."
pdflatex -interaction=nonstopmode "${BASENAME}.tex" >/dev/null 2>&1

# Clean up intermediate files
rm -f "${BASENAME}.tex" "${BASENAME}.aux" "${BASENAME}.log" "${BASENAME}.out"

echo "✓ Success! Generated $OUTPUT_PDF"

# Show page count if pdfinfo is available
if command -v pdfinfo &> /dev/null; then
    PAGES=$(pdfinfo "$OUTPUT_PDF" 2>/dev/null | grep "Pages:" | awk '{print $2}')
    if [ -n "$PAGES" ]; then
        echo "  Pages: $PAGES"
    fi
fi

# Show file size
if [ -f "$OUTPUT_PDF" ]; then
    SIZE=$(ls -lh "$OUTPUT_PDF" | awk '{print $5}')
    echo "  Size: $SIZE"
fi
