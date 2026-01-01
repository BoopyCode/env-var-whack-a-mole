#!/usr/bin/env bash
# ENV Var Whack-a-Mole - Because your variables are playing hide-and-seek

# Configuration - The mole's favorite hiding spots
ENV_FILES=(".env" ".env.local" ".env.production" ".env.staging")
REQUIRED_VARS=()  # Add your variables here, e.g., ("DATABASE_URL" "API_KEY")

# Color codes for maximum dramatic effect
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# The mole detector
check_env_files() {
    echo -e "${YELLOW}🔍 Hunting for environment files...${NC}"
    local found_any=false
    
    for file in "${ENV_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            echo -e "${GREEN}✓ Found: $file${NC}"
            found_any=true
        fi
    done
    
    if [[ "$found_any" == false ]]; then
        echo -e "${RED}❌ No environment files found. The moles have won.${NC}"
        return 1
    fi
    return 0
}

# The variable inspector - catches sneaky disappearing acts
check_required_vars() {
    if [[ ${#REQUIRED_VARS[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No required variables specified. Add some to REQUIRED_VARS array.${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}🔎 Checking for missing variables...${NC}"
    local all_good=true
    
    for var in "${REQUIRED_VARS[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo -e "${RED}❌ Missing: $var (The mole escaped!)${NC}"
            all_good=false
        else
            echo -e "${GREEN}✓ Present: $var${NC}"
        fi
    done
    
    if [[ "$all_good" == false ]]; then
        echo -e "${RED}\n🚨 Some moles are still at large!${NC}"
        return 1
    fi
    
    echo -e "${GREEN}\n🎉 All moles whacked! Environment looks healthy.${NC}"
    return 0
}

# The main event - where we whack those moles
main() {
    echo -e "${YELLOW}=== ENV Var Whack-a-Mole ===${NC}"
    echo -e "${YELLOW}Ready to whack some disappearing variables?${NC}\n"
    
    # Check for environment files
    if ! check_env_files; then
        exit 1
    fi
    
    echo -e "\n${YELLOW}📁 Loading environment files...${NC}"
    
    # Load all found env files (last one wins, like in real life!)
    for file in "${ENV_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            # Safety first - only export simple VAR=value lines
            while IFS='=' read -r key value || [[ -n "$key" ]]; do
                # Skip comments and empty lines
                if [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] && [[ -n "$value" ]]; then
                    export "$key"="$value"
                fi
            done < "$file"
            echo -e "${GREEN}Loaded: $file${NC}"
        fi
    done
    
    echo ""
    
    # Check required variables
    if ! check_required_vars; then
        exit 1
    fi
    
    echo -e "\n${YELLOW}Current environment snapshot:${NC}"
    echo "================================"
    for var in "${REQUIRED_VARS[@]}"; do
        if [[ -n "${!var}" ]]; then
            # Show first 20 chars only (secrets are shy)
            value="${!var}"
            echo "$var=${value:0:20}..."
        fi
    done
}

# Let's whack!
main "$@"
