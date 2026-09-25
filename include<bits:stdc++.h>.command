#!/bin/zsh
# include<bits/stdc++.h>.command
# 生成 bits/stdc++.h 万能头文件
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
TARGET_FOLDER="${SCRIPT_DIR}/bits"
HEADER_FILE="${TARGET_FOLDER}/stdc++.h"

echo "===== Generate bits/stdc++.h Header Library ====="
echo "Output Path: ${HEADER_FILE}"

mkdir -p "${TARGET_FOLDER}"

cat > "${HEADER_FILE}" <<'EOF'
#ifndef _BITS_STDCXX_H
#define _BITS_STDCXX_H

#include <iostream>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <algorithm>
#include <vector>
#include <queue>
#include <stack>
#include <map>
#include <unordered_map>
#include <set>
#include <unordered_set>
#include <string>
#include <sstream>
#include <iomanip>
#include <numeric>
#include <functional>
#include <climits>
#include <cfloat>
#include <ctime>
#include <cstdlib>
#include <bitset>
#include <deque>
#include <list>
#include <utility>
#include <tuple>
#include <iterator>
#include <typeinfo>
#include <memory>
#include <regex>

#endif
EOF

if [ -f "${HEADER_FILE}" ]; then
    echo "Done: bits/stdc++.h created successfully"
    echo "Info: When compiling, add -I${SCRIPT_DIR} to compiler arguments"
else
    echo "Error: Failed to create header file"
    exit 1
fi
