#!/usr/bin/env bash

echo "check variables..."

if [ -z "$USER_NAME" ] ; then echo "Missing \$USER_NAME variable set" ; exit 1 ; fi
if [ -z "$REPO_NAME" ] ; then echo "Missing \$REPO_NAME variable set" ; exit 1 ; fi
if [ -z "$ARTIFACT" ] ; then echo "Missing \$ARTIFACT variable set" ; exit 1 ; fi
if [ -z "$GROUP" ] ; then echo "Missing \$GROUP variable set" ; exit 1 ; fi
if [ -z "$PKG_NAME" ] ; then
  echo "Missing \$PKG_NAME variable set."
  PKG_NAME=$GROUP.$ARTIFACT
  echo "\$PKG_NAME set to $PKG_NAME (as GROUP.ARTIFACT)"
fi
echo "done"

git clone https://github.com/state303/release-please-template.git

mv release-please-template "$REPO_NAME" || { echo "Failed to locate release-please-template" ; exit 1; }
cd "$REPO_NAME" || { echo "Failed to locate $REPO_NAME"; exit 1; }

echo "resetting git..."
rm -rf .git
git init
echo "done"

echo "replacing CHANGELOG.md"
rm CHANGELOG.md && touch CHANGELOG.md
echo "done"

PREV_USER="state303"
PREV_REPO="release-please-template"
PREV_GROUP="io.dsub"

echo "replacing properties..."
if [[ $OSTYPE == 'darwin'* ]]; then
  sed -i '' "s/$PREV_REPO/$ARTIFACT/" settings.gradle
  echo "artifact set"
  sed -i '' "s/$PREV_GROUP/$GROUP/" gradle.properties
  echo "group set"
  sed -i '' "s%$PREV_USER/$PREV_REPO%$USER_NAME/$REPO_NAME%" gradle.properties
  echo "github_repo set"
  sed -i '' "s/artifact_version.*/artifact_version = 0.0.0/" gradle.properties
  echo "artifact_version set"
  sed -i '' "s/$PREV_REPO/$PKG_NAME/" .github/workflows/release.yml
  echo "package-name set"
else
  sed -i "s/$PREV_REPO/$ARTIFACT/" settings.gradle
  echo "artifact set"
  sed -i "s/$PREV_GROUP/$GROUP/" gradle.properties
  echo "group set"
  sed -i "s%$PREV_USER/$PREV_REPO%$USER_NAME/$REPO_NAME%" gradle.properties
  echo "github_repo set"
  sed -i "s/artifact_version.*/artifact_version = 0.0.0/" gradle.properties
  echo "artifact_version set"
  sed -i "s/$PREV_REPO/$PKG_NAME/" .github/workflows/release.yml
  echo "package-name set"
fi
echo "done"

echo "applying java package directory..."
rm -rf src/main/java/io
mkdir -p src/main/java/"$(echo "$GROUP" | sed 's/\./\//')"
echo "done"

echo "removing script..."
rm generate.sh
echo "done"
