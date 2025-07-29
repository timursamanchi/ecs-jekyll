#!/bin/bash

set -e

echo "🔄 Cleaning up all existing Buildx builders..."

# Get unique builder names from buildx ls
builder_names=$(docker buildx ls | awk 'NR>1 {print $1}' | sort -u | grep -v '^$')

if [ -n "$builder_names" ]; then
  for builder in $builder_names; do
    echo "🗑 Removing builder: $builder"
    docker buildx rm "$builder" || echo "⚠️ Skipping: builder '$builder' not found or already removed."
  done
else
  echo "✅ No existing builders found."
fi

echo ""
echo "🛠 Creating new builder: mybuilder"
docker buildx create --use --name mybuilder --driver docker-container

echo ""
echo "🚀 Bootstrapping builder..."
docker buildx inspect --bootstrap

echo ""
echo "✅ Done. Here's your current builder:"
docker buildx ls

echo ""
echo "🔧 You can now start using 'docker buildx' commands with the new builder"