#!/bin/bash
# Check Flutter test coverage
#
# Usage:
#   ./scripts/check-coverage.sh                    # Just print coverage %
#   ./scripts/check-coverage.sh --min 80           # Fail if below 80%
#
# Excludes auto-generated files:
# - lib/src/rust/ (flutter_rust_bridge)
# - *.freezed.dart (freezed)
# - *.g.dart (json_serializable, etc.)

set -euo pipefail

# Default values
LCOV_FILE="coverage/lcov.info"
MIN_COVERAGE=""


print_error() {
    local red_color="\e[31;1m%s\e[0m\n"
    printf "${red_color}" "$1" >&2
}

print_success() {
    local green_color="\e[32;1m%s\e[0m\n"
    printf "${green_color}" "$1" >&2
}

raise_error() {
    print_error "$1"
    exit 1
}


parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --min)
                MIN_COVERAGE="$2"
                shift 2
                ;;
            *)
                LCOV_FILE="$1"
                shift
                ;;
        esac
    done
}

check_lcov_file_presence() {
    if [ ! -f "$LCOV_FILE" ]; then
        raise_error "Error: $LCOV_FILE not found. Run 'flutter test --coverage' first."
    fi
}

filter_generated_files() {
    awk '
    BEGIN { skip = 0 }
    /^SF:/ {
        file = substr($0, 4)
        skip = 0
        if (match(file, /lib\/src\/rust\//) ||
            match(file, /\.freezed\.dart$/) ||
            match(file, /\.g\.dart$/)) {
            skip = 1
        }
    }
    /^end_of_record$/ {
        if (!skip) print
        skip = 0
        next
    }
    { if (!skip) print }
    ' "$LCOV_FILE" > "${LCOV_FILE}.tmp"
    mv "${LCOV_FILE}.tmp" "$LCOV_FILE"
}

calculate_coverage() {
    awk '
    BEGIN {
        total_lines = 0
        covered_lines = 0
        skip = 0
    }
    /^SF:/ {
        file = substr($0, 4)
        skip = 0
        if (match(file, /lib\/src\/rust\//) ||
            match(file, /\.freezed\.dart$/) ||
            match(file, /\.g\.dart$/)) {
            skip = 1
        }
    }
    /^LF:/ {
        if (!skip) total_lines += substr($0, 4)
    }
    /^LH:/ {
        if (!skip) covered_lines += substr($0, 4)
    }
    END {
        if (total_lines > 0) {
            printf "%.2f\n", (covered_lines / total_lines) * 100
        } else {
            print "0.00"
        }
    }
    ' "$LCOV_FILE"
}

check_coverage_threshold() {
    local coverage="$1"
    local min_coverage="$2"

    if (( $(awk "BEGIN {print ($coverage >= $min_coverage)}") )); then
        return 0
    fi
    return 1
}

print_coverage_result() {
    local coverage="$1"
    local min_coverage="$2"

    if check_coverage_threshold "$coverage" "$min_coverage"; then
        print_success "✅ Coverage: ${coverage}%"
        exit 0
    else
        print_error "❌ Coverage: ${coverage}% (below minimum ${min_coverage}%)"
        exit 1
    fi
}


main() {
    parse_arguments "$@"
    check_lcov_file_presence
    filter_generated_files

    local coverage
    coverage=$(calculate_coverage)

    if [ -z "$MIN_COVERAGE" ]; then
        echo "$coverage"
        exit 0
    fi

    print_coverage_result "$coverage" "$MIN_COVERAGE"
}

main "$@"
