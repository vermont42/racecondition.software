#!/bin/bash

echo "Create a new post"
echo ""

while true; do
    read -p "Enter date (YYYY-MM-DD): " DATE

    if [[ ! ($DATE =~ ^[0-9]{4}\-[0-9]{2}\-[0-9]{2}$) ]]; then
        echo ""
        echo "💥  invalid: date must have format YYYY-MM-DD. Found '$DATE'."
        echo ""
    else
        break
    fi
done

while true; do
    read -p "Enter slug (alphanumeric with dashes): " SLUG

    if [[ ! ($SLUG =~ ^[A-Za-z0-9\-]+$) ]]; then
        echo ""
        echo "💥  invalid: slug must be alphanumeric with dashes. Found '$SLUG'."
        echo ""
    else
        break
    fi
done

read -p "Enter title (human-readable, defaults to slug): " TITLE
TITLE=${TITLE:-$SLUG}

POST_DIR="_drafts"

echo "Generate a post or a draft?"
select pd in "post" "draft"; do
    case $pd in
        post )
            echo "Generating new post in _posts/ ...";
            POST_DIR="_posts";
    break;;
        draft )
            echo "Generating new post in _drafts/ ...";
    break;;
    esac
done

mkdir -p "$POST_DIR"

POST="$POST_DIR/$DATE-$SLUG.md"
touch $POST

echo "---
layout: post
title: \"$TITLE\"
subtitle: null
image:
    file: TODO
    alt: TODO
    caption: null
    source_link: null
    half_width: false
---

> TODO: excerpt here

<!--excerpt-->

> TODO: content here

<!--image example-->

{% include image.html
    file=TODO
    alt=TODO
    caption=null
    source_link=null
    half_width=false
%}

" > $POST

echo "Successfully created '$POST'"
echo "Opening..."
echo ""
open $POST
