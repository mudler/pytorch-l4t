#!/bin/bash
# Convert sm_XX format to numeric format for TORCH_CUDA_ARCH_LIST
# sm_75 -> 7.5, sm_80 -> 8.0, sm_90a -> 9.0a, sm_121 -> 12.1, etc.

convert_arch() {
    local arch="$1"
    if [[ ! "$arch" =~ ^sm_ ]]; then
        echo "$arch"
        return
    fi
    
    # Remove sm_ prefix
    local num_suffix="${arch#sm_}"
    
    # Extract numeric part and suffix
    local num_part="${num_suffix%%[a-z]*}"
    local suffix="${num_suffix#$num_part}"
    
    # Convert based on number of digits
    if [ ${#num_part} -eq 2 ]; then
        # Two digits: sm_75 -> 7.5
        echo "${num_part:0:1}.${num_part:1:1}${suffix}"
    elif [ ${#num_part} -eq 3 ]; then
        # Three digits: sm_121 -> 12.1
        echo "${num_part:0:2}.${num_part:2:1}${suffix}"
    else
        # Fallback: just return as-is
        echo "$arch"
    fi
}

# Main: convert comma-separated list
if [ $# -eq 0 ]; then
    echo "Usage: $0 <comma-separated-arch-list>"
    exit 1
fi

IFS=',' read -ra ARCHS <<< "$1"
result=""
for arch in "${ARCHS[@]}"; do
    arch=$(echo "$arch" | xargs)  # trim whitespace
    if [ -n "$result" ]; then
        result="${result},"
    fi
    result="${result}$(convert_arch "$arch")"
done

echo "$result"


