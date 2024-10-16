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
SERVER_STATE_2=${SERVER_STATE_2:-Stopped}
SERVER_STATE_3=${SERVER_STATE_3:-Stopped}
SERVER_STATE_4=${SERVER_STATE_4:-Stopped}
SERVER_STATE_5=${SERVER_STATE_5:-Stopped}
SERVER_STATE_6=${SERVER_STATE_6:-Stopped}
SERVER_STATE_7=${SERVER_STATE_7:-Stopped}
SERVER_STATE_8=${SERVER_STATE_8:-Stopped}
SERVER_STATE_9=${SERVER_STATE_9:-Stopped}
SERVER_STATE_10=${SERVER_STATE_10:-Stopped}
SERVER_STATE_11=${SERVER_STATE_11:-Stopped}
SERVER_STATE_12=${SERVER_STATE_12:-Stopped}
SERVER_STATE_13=${SERVER_STATE_13:-Stopped}
SERVER_STATE_14=${SERVER_STATE_14:-Stopped}
SERVER_STATE_15=${SERVER_STATE_15:-Stopped}
SERVER_STATE_16=${SERVER_STATE_16:-Stopped}
SERVER_STATE_17=${SERVER_STATE_17:-Stopped}
SERVER_STATE_18=${SERVER_STATE_18:-Stopped}
SERVER_STATE_19=${SERVER_STATE_19:-Stopped}
SERVER_STATE_20=${SERVER_STATE_20:-Stopped}
SERVER_STATE_21=${SERVER_STATE_21:-Stopped}
SERVER_STATE_22=${SERVER_STATE_22:-Stopped}
SERVER_STATE_23=${SERVER_STATE_23:-Stopped}
SERVER_STATE_24=${SERVER_STATE_24:-Stopped}
SERVER_STATE_25=${SERVER_STATE_25:-Stopped}
SERVER_STATE_26=${SERVER_STATE_26:-Stopped}
SERVER_STATE_27=${SERVER_STATE_27:-Stopped}
SERVER_STATE_28=${SERVER_STATE_28:-Stopped}
SERVER_STATE_29=${SERVER_STATE_29:-Stopped}
SERVER_STATE_30=${SERVER_STATE_30:-Stopped}
SERVER_STATE_31=${SERVER_STATE_31:-Stopped}
SERVER_STATE_32=${SERVER_STATE_32:-Stopped}
SERVER_STATE_33=${SERVER_STATE_33:-Stopped}
SERVER_STATE_34=${SERVER_STATE_34:-Stopped}
SERVER_STATE_35=${SERVER_STATE_35:-Stopped}
SERVER_STATE_36=${SERVER_STATE_36:-Stopped}
SERVER_STATE_37=${SERVER_STATE_37:-Stopped}
SERVER_STATE_38=${SERVER_STATE_38:-Stopped}
SERVER_STATE_39=${SERVER_STATE_39:-Stopped}
SERVER_STATE_40=${SERVER_STATE_40:-Stopped}
SERVER_STATE_41=${SERVER_STATE_41:-Stopped}
SERVER_STATE_42=${SERVER_STATE_42:-Stopped}
SERVER_STATE_43=${SERVER_STATE_43:-Stopped}
SERVER_STATE_44=${SERVER_STATE_44:-Stopped}
SERVER_STATE_45=${SERVER_STATE_45:-Stopped}
SERVER_STATE_46=${SERVER_STATE_46:-Stopped}
SERVER_STATE_47=${SERVER_STATE_47:-Stopped}
SERVER_STATE_48=${SERVER_STATE_48:-Stopped}
SERVER_STATE_49=${SERVER_STATE_49:-Stopped}
SERVER_STATE_50=${SERVER_STATE_50:-Stopped}
RECORD_NAME_1=${RECORD_NAME_1:-""}
RECORD_NAME_2=${RECORD_NAME_2:-""}
RECORD_NAME_3=${RECORD_NAME_3:-""}
RECORD_NAME_4=${RECORD_NAME_4:-""}
RECORD_NAME_5=${RECORD_NAME_5:-""}
RECORD_NAME_6=${RECORD_NAME_6:-""}
RECORD_NAME_7=${RECORD_NAME_7:-""}
RECORD_NAME_8=${RECORD_NAME_8:-""}
RECORD_NAME_9=${RECORD_NAME_9:-""}
RECORD_NAME_10=${RECORD_NAME_10:-""}
RECORD_NAME_11=${RECORD_NAME_11:-""}
RECORD_NAME_12=${RECORD_NAME_12:-""}
RECORD_NAME_13=${RECORD_NAME_13:-""}
RECORD_NAME_14=${RECORD_NAME_14:-""}
RECORD_NAME_15=${RECORD_NAME_15:-""}
RECORD_NAME_16=${RECORD_NAME_16:-""}
RECORD_NAME_17=${RECORD_NAME_17:-""}
RECORD_NAME_18=${RECORD_NAME_18:-""}
RECORD_NAME_19=${RECORD_NAME_19:-""}
RECORD_NAME_20=${RECORD_NAME_20:-""}
RECORD_NAME_21=${RECORD_NAME_21:-""}
RECORD_NAME_22=${RECORD_NAME_22:-""}
RECORD_NAME_23=${RECORD_NAME_23:-""}
RECORD_NAME_24=${RECORD_NAME_24:-""}
RECORD_NAME_25=${RECORD_NAME_25:-""}
RECORD_NAME_26=${RECORD_NAME_26:-""}
RECORD_NAME_27=${RECORD_NAME_27:-""}
RECORD_NAME_28=${RECORD_NAME_28:-""}
RECORD_NAME_29=${RECORD_NAME_29:-""}
RECORD_NAME_30=${RECORD_NAME_30:-""}
RECORD_NAME_31=${RECORD_NAME_31:-""}
RECORD_NAME_32=${RECORD_NAME_32:-""}
RECORD_NAME_33=${RECORD_NAME_33:-""}
RECORD_NAME_34=${RECORD_NAME_34:-""}
RECORD_NAME_35=${RECORD_NAME_35:-""}
RECORD_NAME_36=${RECORD_NAME_36:-""}
RECORD_NAME_37=${RECORD_NAME_37:-""}
RECORD_NAME_38=${RECORD_NAME_38:-""}
RECORD_NAME_39=${RECORD_NAME_39:-""}
RECORD_NAME_40=${RECORD_NAME_40:-""}
RECORD_NAME_41=${RECORD_NAME_41:-""}
RECORD_NAME_42=${RECORD_NAME_42:-""}
RECORD_NAME_43=${RECORD_NAME_43:-""}
RECORD_NAME_44=${RECORD_NAME_44:-""}
RECORD_NAME_45=${RECORD_NAME_45:-""}
RECORD_NAME_46=${RECORD_NAME_46:-""}
RECORD_NAME_47=${RECORD_NAME_47:-""}
RECORD_NAME_48=${RECORD_NAME_48:-""}
RECORD_NAME_49=${RECORD_NAME_49:-""}
RECORD_NAME_50=${RECORD_NAME_50:-""}

# Function to generate and upload factorio.config.json
generate_and_upload_config() {
    local config_content="{\n  \"routes\": {"
    local first_entry=true

    for asg_num in $(seq 1 50)
    do
        local route_name="RECORD_NAME_${asg_num}"
        if [ "x${!route_name}" != "x" ]; then
            if [ "$first_entry" = false ]; then
                config_content="$config_content,"
            fi
            config_content="$config_content\n    \"server-${asg_num}\": \"${!route_name}\""
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
        ParameterKey=ServerState2,ParameterValue="$SERVER_STATE_2" \
        ParameterKey=ServerState3,ParameterValue="$SERVER_STATE_3" \
        ParameterKey=ServerState4,ParameterValue="$SERVER_STATE_4" \
        ParameterKey=ServerState5,ParameterValue="$SERVER_STATE_5" \
        ParameterKey=ServerState6,ParameterValue="$SERVER_STATE_6" \
        ParameterKey=ServerState7,ParameterValue="$SERVER_STATE_7" \
        ParameterKey=ServerState8,ParameterValue="$SERVER_STATE_8" \
        ParameterKey=ServerState9,ParameterValue="$SERVER_STATE_9" \
        ParameterKey=ServerState10,ParameterValue="$SERVER_STATE_10" \
        ParameterKey=ServerState11,ParameterValue="$SERVER_STATE_11" \
        ParameterKey=ServerState12,ParameterValue="$SERVER_STATE_12" \
        ParameterKey=ServerState13,ParameterValue="$SERVER_STATE_13" \
        ParameterKey=ServerState14,ParameterValue="$SERVER_STATE_14" \
        ParameterKey=ServerState15,ParameterValue="$SERVER_STATE_15" \
        ParameterKey=ServerState16,ParameterValue="$SERVER_STATE_16" \
        ParameterKey=ServerState17,ParameterValue="$SERVER_STATE_17" \
        ParameterKey=ServerState18,ParameterValue="$SERVER_STATE_18" \
        ParameterKey=ServerState19,ParameterValue="$SERVER_STATE_19" \
        ParameterKey=ServerState20,ParameterValue="$SERVER_STATE_20" \
        ParameterKey=ServerState21,ParameterValue="$SERVER_STATE_21" \
        ParameterKey=ServerState22,ParameterValue="$SERVER_STATE_22" \
        ParameterKey=ServerState23,ParameterValue="$SERVER_STATE_23" \
        ParameterKey=ServerState24,ParameterValue="$SERVER_STATE_24" \
        ParameterKey=ServerState25,ParameterValue="$SERVER_STATE_25" \
        ParameterKey=ServerState26,ParameterValue="$SERVER_STATE_26" \
        ParameterKey=ServerState27,ParameterValue="$SERVER_STATE_27" \
        ParameterKey=ServerState28,ParameterValue="$SERVER_STATE_28" \
        ParameterKey=ServerState29,ParameterValue="$SERVER_STATE_29" \
        ParameterKey=ServerState30,ParameterValue="$SERVER_STATE_30" \
        ParameterKey=ServerState31,ParameterValue="$SERVER_STATE_31" \
        ParameterKey=ServerState32,ParameterValue="$SERVER_STATE_32" \
        ParameterKey=ServerState33,ParameterValue="$SERVER_STATE_33" \
        ParameterKey=ServerState34,ParameterValue="$SERVER_STATE_34" \
        ParameterKey=ServerState35,ParameterValue="$SERVER_STATE_35" \
        ParameterKey=ServerState36,ParameterValue="$SERVER_STATE_36" \
        ParameterKey=ServerState37,ParameterValue="$SERVER_STATE_37" \
        ParameterKey=ServerState38,ParameterValue="$SERVER_STATE_38" \
        ParameterKey=ServerState39,ParameterValue="$SERVER_STATE_39" \
        ParameterKey=ServerState40,ParameterValue="$SERVER_STATE_40" \
        ParameterKey=ServerState41,ParameterValue="$SERVER_STATE_41" \
        ParameterKey=ServerState42,ParameterValue="$SERVER_STATE_42" \
        ParameterKey=ServerState43,ParameterValue="$SERVER_STATE_43" \
        ParameterKey=ServerState44,ParameterValue="$SERVER_STATE_44" \
        ParameterKey=ServerState45,ParameterValue="$SERVER_STATE_45" \
        ParameterKey=ServerState46,ParameterValue="$SERVER_STATE_46" \
        ParameterKey=ServerState47,ParameterValue="$SERVER_STATE_47" \
        ParameterKey=ServerState48,ParameterValue="$SERVER_STATE_48" \
        ParameterKey=ServerState49,ParameterValue="$SERVER_STATE_49" \
        ParameterKey=ServerState50,ParameterValue="$SERVER_STATE_50" \
        --capabilities CAPABILITY_IAM
}

# Generate and upload the config file
generate_and_upload_config

# Update the CloudFormation stack
update_stack
