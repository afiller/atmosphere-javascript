#!/bin/bash

# 
#  Copyright (C) Pathmate Technologies AG - All Rights Reserved
# 
#  Unauthorized copying of this file, via any medium is strictly prohibited.
# 
#  Proprietary and confidential.
# 
#  Written by Andreas Filler (CTO) in behalf of Pathmate Technologies AG.
# 
#  Zurich, Switzerland, April 2026.
# 
#  In case of questions contact us at contact@pathmate-technologies.com .
# 

# Basic setup
PLATFORM=$(uname -s)
if [ "$PLATFORM" = "Darwin" ]
	then
	export LC_CTYPE=C
	export LANG=C
	alias readlink=greadlink
fi
DIR=$(dirname "$(readlink -f "$0" || realpath "$0")")

# Change to path
cd "$DIR"

# Properties file
PROPS_FILE="${DIR}/version.properties"

if [ ! -f "${PROPS_FILE}" ]; then
	echo "ERROR: ${PROPS_FILE} not found." >&2
	exit 1
fi

# Read base version (strip trailing number, replace with 000)
VERSION=$(grep "^version=" "${PROPS_FILE}" | cut -d'=' -f2)
VERSION_BASE=$(echo "$VERSION" | sed 's/-pathmate-[0-9]*$/-pathmate-000/')

echo "Resetting version to: $VERSION_BASE"

# Reset all Pathmate versions to 000 in all pom.xml files
find "$DIR" -name "pom.xml" -print | while read -r POM; do
	if grep -q "pathmate" "$POM"; then
		sed -i '' "s|[0-9][0-9.]*-pathmate-[0-9]*|${VERSION_BASE}|g" "$POM"
		echo "  Cleared: $POM"
	fi
done

# Reset version in atmosphere.js and jquery.atmosphere.js
ATMOSPHERE_JS="${DIR}/modules/javascript/src/main/webapp/javascript/atmosphere.js"
JQUERY_ATMOSPHERE_JS="${DIR}/modules/jquery/src/main/webapp/jquery/jquery.atmosphere.js"

if [ -f "${ATMOSPHERE_JS}" ]; then
	sed -i '' "s|[0-9][0-9.]*-pathmate-[^\"]*-javascript|${VERSION_BASE}-javascript|g" "${ATMOSPHERE_JS}"
	echo "  Cleared: ${ATMOSPHERE_JS}"
fi

if [ -f "${JQUERY_ATMOSPHERE_JS}" ]; then
	sed -i '' "s|[0-9][0-9.]*-pathmate-[^\"]*-jquery|${VERSION_BASE}-jquery|g" "${JQUERY_ATMOSPHERE_JS}"
	echo "  Cleared: ${JQUERY_ATMOSPHERE_JS}"
fi

echo "Done."
