#!/bin/bash

# Function to get destination folder based on extension
get_destination() {
    local ext=$1
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    case "$ext" in
        jpg|jpeg|heic|avif|webp|bmp|tiff|png|gif|ico)
            echo "Images"
            ;;
        pdf|doc|docx|txt|csv|xls|xlsx|ppt|odt)
            echo "Documents"
            ;;
        mp4|mkv|avi|mov|wmv|webm)
            echo "Videos"
            ;;
        mp3|wav|flac|aac)
            echo "Audio"
            ;;
        zip|7z|tar|gz|rar|apk)
            echo "Archives"
            ;;
        js|ts|jsx|tsx|py|java|c|cpp|h|hpp|rb|php|go|rs|swift|kt|lua|sql|sh|bash|json|yaml|xml|html|css)
            echo "Code"
            ;;
        exe|msi|dmg|pkg|deb|rpm|bin|run|sh)
            echo "Apps"
            ;;
        psd|ai|eps|sketch)
            echo "Design"
            ;;
        sql|sqlite|mysql|mongodb|db)
            echo "Databases"
            ;;
        *)
            echo "Misc"
            ;;
    esac
}

# Function to zip large folders
zip_folder() {
    local folder=$1
    local zip_name="${folder}.zip"
    
    if [ ! -d "$folder" ]; then
        return 1
    fi
    
    if ! command -v zip &> /dev/null; then
        return 1
    fi
    
    zip -r "$zip_name" "$folder" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        rm -rf "$folder"
        echo "$zip_name"
    else
        return 1
    fi
}

# Main execution
main() {
    # Process files in the current directory (downloads)
    for file in *; do
        # Skip directories
        if [ -d "$file" ]; then
            # Skip category folders
            case "$file" in
                Images|Documents|Videos|Audio|Code|Apps|Archives|Design|Databases|Misc)
                    continue
                    ;;
            esac
            
            # Check if folder should be zipped (large folders)
            local folder_size=$(du -s "$file" 2>/dev/null | cut -f1)
            local threshold=102400  # 100MB in KB
            
            if [ "$folder_size" -gt "$threshold" ]; then
                zip_result=$(zip_folder "$file")
                if [ -n "$zip_result" ]; then
                    file="$zip_result"
                else
                    continue
                fi
            else
                continue
            fi
        fi
        
        # Skip this script and log files
        if [[ "$file" == "organizer.sh" ]]; then
            continue
        fi
        
        # Skip if not a file
        if [ ! -f "$file" ]; then
            continue
        fi
        
        # Extract file extension
        local ext="${file##*.}"
        local filename="${file%.*}"
        
        # Handle files without extension
        if [ "$ext" = "$file" ]; then
            ext=""
        fi
        
        # Get destination folder
        local dest=$(get_destination "$ext")
        
        # Create destination folder
        mkdir -p "$dest"
        
        # Check if file already exists in destination
        if [ -f "$dest/$file" ]; then
            # Generate unique filename
            local timestamp=$(date +%s)
            local new_filename="${filename}_${timestamp}.${ext}"
            mv "$file" "$dest/$new_filename"
        else
            mv "$file" "$dest/"
        fi
    done
    echo "Cleanup complete!" 
}

# Run main function
main