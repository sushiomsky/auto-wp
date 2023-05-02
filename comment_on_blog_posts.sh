#!/bin/bash

# Replace the following variables with your actual values
WP_PATH="/path/to/your/wordpress/installation"
API_KEY="your_openai_api_key"

# Get a list of recent blog post IDs
post_ids=$(wp post list --post_type=post --post_status=publish --field=ID --path="$WP_PATH")

# Loop through each blog post ID
for post_id in $post_ids; do
    # Get the post title and content
    post_title=$(wp post get $post_id --field=title --path="$WP_PATH")
    post_content=$(wp post get $post_id --field=content --path="$WP_PATH")

    # Combine the post title and content as input for the ChatGPT API
    input_text="Post title: $post_title. Post content: $post_content. Please provide a relevant comment."

    # Call the ChatGPT API to generate a comment
    response=$(curl -s -X POST "https://api.openai.com/v1/engines/davinci-codex/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"prompt\": \"$input_text\", \"max_tokens\": 50, \"n\": 1, \"stop\": null, \"temperature\": 0.5}")

    # Extract the generated comment from the API response
    comment_text=$(echo $response | jq -r '.choices[0].text' | tr -d '\n')

    # Add the generated comment to the blog post
    wp comment create --comment_post_ID=$post_id --comment_content="$comment_text" --comment_author="ChatGPT" --comment_author_email="chatgpt@example.com" --path="$WP_PATH"
done
