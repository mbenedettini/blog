#!/bin/bash

for file in ./astro/src/content/blog/*/index.md; do
    temp_file=$(mktemp)
    
    awk '
    BEGIN {in_frontmatter=0; frontmatter_end=0; has_description=0; has_pubDatetime=0}
    /^---$/ {
        if (in_frontmatter) {
            in_frontmatter=0;
            frontmatter_end=1;
            if (!has_description) print "description: \"\"";
            if (!has_pubDatetime) print "pubDatetime:", strftime("%Y-%m-%d", systime());
        } else {
            in_frontmatter=1;
        }
        print;
        next;
    }
    in_frontmatter {
        if ($1 == "date:") {
            print "pubDatetime:", $2;
            has_pubDatetime=1;
        } else if ($1 == "description:") {
            print;
            has_description=1;
        } else {
            print;
        }
        next;
    }
    frontmatter_end || /^---$/ {frontmatter_end=0; print; next}
    {print}
    ' "$file" > "$temp_file"
    
    mv "$temp_file" "$file"
done