#!/bin/bash

# Function to get public IP address
get_public_ip() {
    if command -v curl &> /dev/null; then
        curl -s ipinfo.io/ip
    elif command -v wget &> /dev/null; then
        wget -qO- ipinfo.io/ip
    elif command -v dig &> /dev/null; then
        dig +short myip.opendns.com @resolver1.opendns.com
    else
        echo ""
    fi
}

# Default stack name
STACK_NAME=${STACK_NAME:-factorio-servers}

# Get public IP address
PUBLIC_IP=$(get_public_ip)

# Default parameter values
ECSAMI=${ECSAMI:-/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id}
FACTORIO_IMAGE_TAG=${FACTORIO_IMAGE_TAG:-latest}
INSTANCE_TYPE=${INSTANCE_TYPE:-m6a.large}
SPOT_PRICE=${SPOT_PRICE:-0.05}
KEY_PAIR_NAME=${KEY_PAIR_NAME:-""}
YOUR_IP=${YOUR_IP:-$PUBLIC_IP}
HOSTED_ZONE_ID=${HOSTED_ZONE_ID:-""}
SUB_DOMAIN_PREFIX=${SUB_DOMAIN_PREFIX:-"factorio-"}
ENABLE_RCON=${ENABLE_RCON:-false}
UPDATE_MODS_ON_START=${UPDATE_MODS_ON_START:-false}

# Server Specific variables

SERVER_STATE_1=${SERVER_STATE_1:-Stopped}
RECORD_NAME_1=${RECORD_NAME_1:-""}

# Function to generate and upload factorio.config.json
generate_and_upload_config() {
    local config_content="{\n  \"routes\": {"
    local first_entry=true

    for i in seq 1 
    do
        local route_name="ROUTE_NAME_$i"
        if [ -n "${!route_name}" ]; then
            if [ "$first_entry" = false ]; then
                config_content="$config_content,"
            fi
            config_content="$config_content\n    \"server-$i\": \"${!route_name}\""
            first_entry=false
        fi
    done

    config_content="$config_content\n  }\n}"

    # Create a temporary file
    local temp_file=$(mktemp)

    # Write JSON content to the temporary file
    echo -e "$config_content" > "$temp_file"

    # Display the content of the JSON file
    echo "Generated JSON content:"
    cat "$temp_file"
    echo

    # Upload the file to S3
    local s3_bucket="${STACK_NAME}-config"
    aws s3 cp "$temp_file" "s3://$s3_bucket/factorio.config.json"

    # Check if the upload was successful
    if [ $? -eq 0 ]; then
        echo "Successfully uploaded factorio.config.json to s3://${s3_bucket}/"
    else
        echo "Failed to upload factorio.config.json to S3"
    fi

    # Remove the temporary file
    rm "$temp_file"
}

# The update command

update_stack() {
    aws cloudformation update-stack \
        --stack-name "$STACK_NAME" \
        --use-previous-template \
        --parameters \
        ParameterKey=ECSAMI,ParameterValue="$ECSAMI" \
        ParameterKey=FactorioImageTag,ParameterValue="$FACTORIO_IMAGE_TAG" \
        ParameterKey=InstanceType,ParameterValue="$INSTANCE_TYPE" \
        ParameterKey=SpotPrice,ParameterValue="$SPOT_PRICE" \
        ParameterKey=KeyPairName,ParameterValue="$KEY_PAIR_NAME" \
        ParameterKey=YourIp,ParameterValue="$YOUR_IP" \
        ParameterKey=HostedZoneId,ParameterValue="$HOSTED_ZONE_ID" \
        ParameterKey=SubDomainPrefix,ParameterValue="$SUB_DOMAIN_PREFIX" \
        ParameterKey=EnableRcon,ParameterValue="$ENABLE_RCON" \
        ParameterKey=UpdateModsOnStart,ParameterValue="$UPDATE_MODS_ON_START" \
        ParameterKey=ServerState1,ParameterValue="$SERVER_STATE_1" \
        --capabilities CAPABILITY_IAM
}

# Generate and upload the config file
generate_and_upload_config

# Update the CloudFormation stack
update_stack
