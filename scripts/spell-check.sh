#!/bin/bash
# Local spell check script for content directory

set -e

echo "🔍 Running spell check on content directory..."

# Check if hunspell is installed
if ! command -v hunspell &> /dev/null; then
    echo "❌ hunspell is not installed. Please install it:"
    echo "   Ubuntu/Debian: sudo apt-get install hunspell hunspell-en-us"
    echo "   macOS: brew install hunspell"
    echo "   Fedora: sudo dnf install hunspell hunspell-en-US"
    exit 1
fi

# Check if personal dictionary exists
if [ ! -f ".hunspell_personal" ]; then
    echo "⚠️  Personal dictionary not found. Creating one..."
    cat > .hunspell_personal << 'EOF'
personal_ws-1.1 en 0 utf-8
CDC's
wordle
LinkedIn
DuckDB
Polars
Nushell
Github
uv
Sci-Fi
Fi
EOF
    echo "✅ Created .hunspell_personal"
fi

# Function to check spelling
check_spelling() {
    local exit_code=0
    local total_files=0
    local files_with_errors=0

    echo ""

    while IFS= read -r -d '' file; do
        total_files=$((total_files + 1))
        echo -n "Checking: $file ... "

        # Get misspelled words
        misspelled=$(hunspell -p .hunspell_personal -l "$file" 2>/dev/null || true)

        if [ -n "$misspelled" ]; then
            echo "❌"
            echo "  Misspelled words:"
            echo "$misspelled" | sed 's/^/    - /'
            echo ""
            files_with_errors=$((files_with_errors + 1))
            exit_code=1
        else
            echo "✅"
        fi
    done < <(find content -name "*.md" -print0)

    echo ""
    echo "📊 Summary:"
    echo "  Files checked: $total_files"
    echo "  Files with errors: $files_with_errors"

    if [ $exit_code -eq 0 ]; then
        echo "🎉 All content files passed spell check!"
    else
        echo ""
        echo "💡 Tips:"
        echo "  - Fix spelling errors in the markdown files"
        echo "  - Add technical terms to .hunspell_personal if they're correct"
        echo "  - Personal dictionary format: one word per line after the header"
    fi

    return $exit_code
}

# Run the check
check_spelling
