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
SERVER_STATE_51=${SERVER_STATE_51:-Stopped}
SERVER_STATE_52=${SERVER_STATE_52:-Stopped}
SERVER_STATE_53=${SERVER_STATE_53:-Stopped}
SERVER_STATE_54=${SERVER_STATE_54:-Stopped}
SERVER_STATE_55=${SERVER_STATE_55:-Stopped}
SERVER_STATE_56=${SERVER_STATE_56:-Stopped}
SERVER_STATE_57=${SERVER_STATE_57:-Stopped}
SERVER_STATE_58=${SERVER_STATE_58:-Stopped}
SERVER_STATE_59=${SERVER_STATE_59:-Stopped}
SERVER_STATE_60=${SERVER_STATE_60:-Stopped}
SERVER_STATE_61=${SERVER_STATE_61:-Stopped}
SERVER_STATE_62=${SERVER_STATE_62:-Stopped}
SERVER_STATE_63=${SERVER_STATE_63:-Stopped}
SERVER_STATE_64=${SERVER_STATE_64:-Stopped}
SERVER_STATE_65=${SERVER_STATE_65:-Stopped}
SERVER_STATE_66=${SERVER_STATE_66:-Stopped}
SERVER_STATE_67=${SERVER_STATE_67:-Stopped}
SERVER_STATE_68=${SERVER_STATE_68:-Stopped}
SERVER_STATE_69=${SERVER_STATE_69:-Stopped}
SERVER_STATE_70=${SERVER_STATE_70:-Stopped}
SERVER_STATE_71=${SERVER_STATE_71:-Stopped}
SERVER_STATE_72=${SERVER_STATE_72:-Stopped}
SERVER_STATE_73=${SERVER_STATE_73:-Stopped}
SERVER_STATE_74=${SERVER_STATE_74:-Stopped}
SERVER_STATE_75=${SERVER_STATE_75:-Stopped}
SERVER_STATE_76=${SERVER_STATE_76:-Stopped}
SERVER_STATE_77=${SERVER_STATE_77:-Stopped}
SERVER_STATE_78=${SERVER_STATE_78:-Stopped}
SERVER_STATE_79=${SERVER_STATE_79:-Stopped}
SERVER_STATE_80=${SERVER_STATE_80:-Stopped}
SERVER_STATE_81=${SERVER_STATE_81:-Stopped}
SERVER_STATE_82=${SERVER_STATE_82:-Stopped}
SERVER_STATE_83=${SERVER_STATE_83:-Stopped}
SERVER_STATE_84=${SERVER_STATE_84:-Stopped}
SERVER_STATE_85=${SERVER_STATE_85:-Stopped}
SERVER_STATE_86=${SERVER_STATE_86:-Stopped}
SERVER_STATE_87=${SERVER_STATE_87:-Stopped}
SERVER_STATE_88=${SERVER_STATE_88:-Stopped}
SERVER_STATE_89=${SERVER_STATE_89:-Stopped}
SERVER_STATE_90=${SERVER_STATE_90:-Stopped}
SERVER_STATE_91=${SERVER_STATE_91:-Stopped}
SERVER_STATE_92=${SERVER_STATE_92:-Stopped}
SERVER_STATE_93=${SERVER_STATE_93:-Stopped}
SERVER_STATE_94=${SERVER_STATE_94:-Stopped}
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
RECORD_NAME_51=${RECORD_NAME_51:-""}
RECORD_NAME_52=${RECORD_NAME_52:-""}
RECORD_NAME_53=${RECORD_NAME_53:-""}
RECORD_NAME_54=${RECORD_NAME_54:-""}
RECORD_NAME_55=${RECORD_NAME_55:-""}
RECORD_NAME_56=${RECORD_NAME_56:-""}
RECORD_NAME_57=${RECORD_NAME_57:-""}
RECORD_NAME_58=${RECORD_NAME_58:-""}
RECORD_NAME_59=${RECORD_NAME_59:-""}
RECORD_NAME_60=${RECORD_NAME_60:-""}
RECORD_NAME_61=${RECORD_NAME_61:-""}
RECORD_NAME_62=${RECORD_NAME_62:-""}
RECORD_NAME_63=${RECORD_NAME_63:-""}
RECORD_NAME_64=${RECORD_NAME_64:-""}
RECORD_NAME_65=${RECORD_NAME_65:-""}
RECORD_NAME_66=${RECORD_NAME_66:-""}
RECORD_NAME_67=${RECORD_NAME_67:-""}
RECORD_NAME_68=${RECORD_NAME_68:-""}
RECORD_NAME_69=${RECORD_NAME_69:-""}
RECORD_NAME_70=${RECORD_NAME_70:-""}
RECORD_NAME_71=${RECORD_NAME_71:-""}
RECORD_NAME_72=${RECORD_NAME_72:-""}
RECORD_NAME_73=${RECORD_NAME_73:-""}
RECORD_NAME_74=${RECORD_NAME_74:-""}
RECORD_NAME_75=${RECORD_NAME_75:-""}
RECORD_NAME_76=${RECORD_NAME_76:-""}
RECORD_NAME_77=${RECORD_NAME_77:-""}
RECORD_NAME_78=${RECORD_NAME_78:-""}
RECORD_NAME_79=${RECORD_NAME_79:-""}
RECORD_NAME_80=${RECORD_NAME_80:-""}
RECORD_NAME_81=${RECORD_NAME_81:-""}
RECORD_NAME_82=${RECORD_NAME_82:-""}
RECORD_NAME_83=${RECORD_NAME_83:-""}
RECORD_NAME_84=${RECORD_NAME_84:-""}
RECORD_NAME_85=${RECORD_NAME_85:-""}
RECORD_NAME_86=${RECORD_NAME_86:-""}
RECORD_NAME_87=${RECORD_NAME_87:-""}
RECORD_NAME_88=${RECORD_NAME_88:-""}
RECORD_NAME_89=${RECORD_NAME_89:-""}
RECORD_NAME_90=${RECORD_NAME_90:-""}
RECORD_NAME_91=${RECORD_NAME_91:-""}
RECORD_NAME_92=${RECORD_NAME_92:-""}
RECORD_NAME_93=${RECORD_NAME_93:-""}
RECORD_NAME_94=${RECORD_NAME_94:-""}

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
        ParameterKey=EnableRcon,ParameterValue="$ENABLE_RCON" \
        ParameterKey=UpdateModsOnStart,ParameterValue="$UPDATE_MODS_ON_START" \
        ParameterKey=ServerState1,ParameterValue="$SERVER_STATE_1" \
        ParameterKey=RecordName1,ParameterValue="$RECORD_NAME_1" \
        ParameterKey=ServerState2,ParameterValue="$SERVER_STATE_2" \
        ParameterKey=RecordName2,ParameterValue="$RECORD_NAME_2" \
        ParameterKey=ServerState3,ParameterValue="$SERVER_STATE_3" \
        ParameterKey=RecordName3,ParameterValue="$RECORD_NAME_3" \
        ParameterKey=ServerState4,ParameterValue="$SERVER_STATE_4" \
        ParameterKey=RecordName4,ParameterValue="$RECORD_NAME_4" \
        ParameterKey=ServerState5,ParameterValue="$SERVER_STATE_5" \
        ParameterKey=RecordName5,ParameterValue="$RECORD_NAME_5" \
        ParameterKey=ServerState6,ParameterValue="$SERVER_STATE_6" \
        ParameterKey=RecordName6,ParameterValue="$RECORD_NAME_6" \
        ParameterKey=ServerState7,ParameterValue="$SERVER_STATE_7" \
        ParameterKey=RecordName7,ParameterValue="$RECORD_NAME_7" \
        ParameterKey=ServerState8,ParameterValue="$SERVER_STATE_8" \
        ParameterKey=RecordName8,ParameterValue="$RECORD_NAME_8" \
        ParameterKey=ServerState9,ParameterValue="$SERVER_STATE_9" \
        ParameterKey=RecordName9,ParameterValue="$RECORD_NAME_9" \
        ParameterKey=ServerState10,ParameterValue="$SERVER_STATE_10" \
        ParameterKey=RecordName10,ParameterValue="$RECORD_NAME_10" \
        ParameterKey=ServerState11,ParameterValue="$SERVER_STATE_11" \
        ParameterKey=RecordName11,ParameterValue="$RECORD_NAME_11" \
        ParameterKey=ServerState12,ParameterValue="$SERVER_STATE_12" \
        ParameterKey=RecordName12,ParameterValue="$RECORD_NAME_12" \
        ParameterKey=ServerState13,ParameterValue="$SERVER_STATE_13" \
        ParameterKey=RecordName13,ParameterValue="$RECORD_NAME_13" \
        ParameterKey=ServerState14,ParameterValue="$SERVER_STATE_14" \
        ParameterKey=RecordName14,ParameterValue="$RECORD_NAME_14" \
        ParameterKey=ServerState15,ParameterValue="$SERVER_STATE_15" \
        ParameterKey=RecordName15,ParameterValue="$RECORD_NAME_15" \
        ParameterKey=ServerState16,ParameterValue="$SERVER_STATE_16" \
        ParameterKey=RecordName16,ParameterValue="$RECORD_NAME_16" \
        ParameterKey=ServerState17,ParameterValue="$SERVER_STATE_17" \
        ParameterKey=RecordName17,ParameterValue="$RECORD_NAME_17" \
        ParameterKey=ServerState18,ParameterValue="$SERVER_STATE_18" \
        ParameterKey=RecordName18,ParameterValue="$RECORD_NAME_18" \
        ParameterKey=ServerState19,ParameterValue="$SERVER_STATE_19" \
        ParameterKey=RecordName19,ParameterValue="$RECORD_NAME_19" \
        ParameterKey=ServerState20,ParameterValue="$SERVER_STATE_20" \
        ParameterKey=RecordName20,ParameterValue="$RECORD_NAME_20" \
        ParameterKey=ServerState21,ParameterValue="$SERVER_STATE_21" \
        ParameterKey=RecordName21,ParameterValue="$RECORD_NAME_21" \
        ParameterKey=ServerState22,ParameterValue="$SERVER_STATE_22" \
        ParameterKey=RecordName22,ParameterValue="$RECORD_NAME_22" \
        ParameterKey=ServerState23,ParameterValue="$SERVER_STATE_23" \
        ParameterKey=RecordName23,ParameterValue="$RECORD_NAME_23" \
        ParameterKey=ServerState24,ParameterValue="$SERVER_STATE_24" \
        ParameterKey=RecordName24,ParameterValue="$RECORD_NAME_24" \
        ParameterKey=ServerState25,ParameterValue="$SERVER_STATE_25" \
        ParameterKey=RecordName25,ParameterValue="$RECORD_NAME_25" \
        ParameterKey=ServerState26,ParameterValue="$SERVER_STATE_26" \
        ParameterKey=RecordName26,ParameterValue="$RECORD_NAME_26" \
        ParameterKey=ServerState27,ParameterValue="$SERVER_STATE_27" \
        ParameterKey=RecordName27,ParameterValue="$RECORD_NAME_27" \
        ParameterKey=ServerState28,ParameterValue="$SERVER_STATE_28" \
        ParameterKey=RecordName28,ParameterValue="$RECORD_NAME_28" \
        ParameterKey=ServerState29,ParameterValue="$SERVER_STATE_29" \
        ParameterKey=RecordName29,ParameterValue="$RECORD_NAME_29" \
        ParameterKey=ServerState30,ParameterValue="$SERVER_STATE_30" \
        ParameterKey=RecordName30,ParameterValue="$RECORD_NAME_30" \
        ParameterKey=ServerState31,ParameterValue="$SERVER_STATE_31" \
        ParameterKey=RecordName31,ParameterValue="$RECORD_NAME_31" \
        ParameterKey=ServerState32,ParameterValue="$SERVER_STATE_32" \
        ParameterKey=RecordName32,ParameterValue="$RECORD_NAME_32" \
        ParameterKey=ServerState33,ParameterValue="$SERVER_STATE_33" \
        ParameterKey=RecordName33,ParameterValue="$RECORD_NAME_33" \
        ParameterKey=ServerState34,ParameterValue="$SERVER_STATE_34" \
        ParameterKey=RecordName34,ParameterValue="$RECORD_NAME_34" \
        ParameterKey=ServerState35,ParameterValue="$SERVER_STATE_35" \
        ParameterKey=RecordName35,ParameterValue="$RECORD_NAME_35" \
        ParameterKey=ServerState36,ParameterValue="$SERVER_STATE_36" \
        ParameterKey=RecordName36,ParameterValue="$RECORD_NAME_36" \
        ParameterKey=ServerState37,ParameterValue="$SERVER_STATE_37" \
        ParameterKey=RecordName37,ParameterValue="$RECORD_NAME_37" \
        ParameterKey=ServerState38,ParameterValue="$SERVER_STATE_38" \
        ParameterKey=RecordName38,ParameterValue="$RECORD_NAME_38" \
        ParameterKey=ServerState39,ParameterValue="$SERVER_STATE_39" \
        ParameterKey=RecordName39,ParameterValue="$RECORD_NAME_39" \
        ParameterKey=ServerState40,ParameterValue="$SERVER_STATE_40" \
        ParameterKey=RecordName40,ParameterValue="$RECORD_NAME_40" \
        ParameterKey=ServerState41,ParameterValue="$SERVER_STATE_41" \
        ParameterKey=RecordName41,ParameterValue="$RECORD_NAME_41" \
        ParameterKey=ServerState42,ParameterValue="$SERVER_STATE_42" \
        ParameterKey=RecordName42,ParameterValue="$RECORD_NAME_42" \
        ParameterKey=ServerState43,ParameterValue="$SERVER_STATE_43" \
        ParameterKey=RecordName43,ParameterValue="$RECORD_NAME_43" \
        ParameterKey=ServerState44,ParameterValue="$SERVER_STATE_44" \
        ParameterKey=RecordName44,ParameterValue="$RECORD_NAME_44" \
        ParameterKey=ServerState45,ParameterValue="$SERVER_STATE_45" \
        ParameterKey=RecordName45,ParameterValue="$RECORD_NAME_45" \
        ParameterKey=ServerState46,ParameterValue="$SERVER_STATE_46" \
        ParameterKey=RecordName46,ParameterValue="$RECORD_NAME_46" \
        ParameterKey=ServerState47,ParameterValue="$SERVER_STATE_47" \
        ParameterKey=RecordName47,ParameterValue="$RECORD_NAME_47" \
        ParameterKey=ServerState48,ParameterValue="$SERVER_STATE_48" \
        ParameterKey=RecordName48,ParameterValue="$RECORD_NAME_48" \
        ParameterKey=ServerState49,ParameterValue="$SERVER_STATE_49" \
        ParameterKey=RecordName49,ParameterValue="$RECORD_NAME_49" \
        ParameterKey=ServerState50,ParameterValue="$SERVER_STATE_50" \
        ParameterKey=RecordName50,ParameterValue="$RECORD_NAME_50" \
        ParameterKey=ServerState51,ParameterValue="$SERVER_STATE_51" \
        ParameterKey=RecordName51,ParameterValue="$RECORD_NAME_51" \
        ParameterKey=ServerState52,ParameterValue="$SERVER_STATE_52" \
        ParameterKey=RecordName52,ParameterValue="$RECORD_NAME_52" \
        ParameterKey=ServerState53,ParameterValue="$SERVER_STATE_53" \
        ParameterKey=RecordName53,ParameterValue="$RECORD_NAME_53" \
        ParameterKey=ServerState54,ParameterValue="$SERVER_STATE_54" \
        ParameterKey=RecordName54,ParameterValue="$RECORD_NAME_54" \
        ParameterKey=ServerState55,ParameterValue="$SERVER_STATE_55" \
        ParameterKey=RecordName55,ParameterValue="$RECORD_NAME_55" \
        ParameterKey=ServerState56,ParameterValue="$SERVER_STATE_56" \
        ParameterKey=RecordName56,ParameterValue="$RECORD_NAME_56" \
        ParameterKey=ServerState57,ParameterValue="$SERVER_STATE_57" \
        ParameterKey=RecordName57,ParameterValue="$RECORD_NAME_57" \
        ParameterKey=ServerState58,ParameterValue="$SERVER_STATE_58" \
        ParameterKey=RecordName58,ParameterValue="$RECORD_NAME_58" \
        ParameterKey=ServerState59,ParameterValue="$SERVER_STATE_59" \
        ParameterKey=RecordName59,ParameterValue="$RECORD_NAME_59" \
        ParameterKey=ServerState60,ParameterValue="$SERVER_STATE_60" \
        ParameterKey=RecordName60,ParameterValue="$RECORD_NAME_60" \
        ParameterKey=ServerState61,ParameterValue="$SERVER_STATE_61" \
        ParameterKey=RecordName61,ParameterValue="$RECORD_NAME_61" \
        ParameterKey=ServerState62,ParameterValue="$SERVER_STATE_62" \
        ParameterKey=RecordName62,ParameterValue="$RECORD_NAME_62" \
        ParameterKey=ServerState63,ParameterValue="$SERVER_STATE_63" \
        ParameterKey=RecordName63,ParameterValue="$RECORD_NAME_63" \
        ParameterKey=ServerState64,ParameterValue="$SERVER_STATE_64" \
        ParameterKey=RecordName64,ParameterValue="$RECORD_NAME_64" \
        ParameterKey=ServerState65,ParameterValue="$SERVER_STATE_65" \
        ParameterKey=RecordName65,ParameterValue="$RECORD_NAME_65" \
        ParameterKey=ServerState66,ParameterValue="$SERVER_STATE_66" \
        ParameterKey=RecordName66,ParameterValue="$RECORD_NAME_66" \
        ParameterKey=ServerState67,ParameterValue="$SERVER_STATE_67" \
        ParameterKey=RecordName67,ParameterValue="$RECORD_NAME_67" \
        ParameterKey=ServerState68,ParameterValue="$SERVER_STATE_68" \
        ParameterKey=RecordName68,ParameterValue="$RECORD_NAME_68" \
        ParameterKey=ServerState69,ParameterValue="$SERVER_STATE_69" \
        ParameterKey=RecordName69,ParameterValue="$RECORD_NAME_69" \
        ParameterKey=ServerState70,ParameterValue="$SERVER_STATE_70" \
        ParameterKey=RecordName70,ParameterValue="$RECORD_NAME_70" \
        ParameterKey=ServerState71,ParameterValue="$SERVER_STATE_71" \
        ParameterKey=RecordName71,ParameterValue="$RECORD_NAME_71" \
        ParameterKey=ServerState72,ParameterValue="$SERVER_STATE_72" \
        ParameterKey=RecordName72,ParameterValue="$RECORD_NAME_72" \
        ParameterKey=ServerState73,ParameterValue="$SERVER_STATE_73" \
        ParameterKey=RecordName73,ParameterValue="$RECORD_NAME_73" \
        ParameterKey=ServerState74,ParameterValue="$SERVER_STATE_74" \
        ParameterKey=RecordName74,ParameterValue="$RECORD_NAME_74" \
        ParameterKey=ServerState75,ParameterValue="$SERVER_STATE_75" \
        ParameterKey=RecordName75,ParameterValue="$RECORD_NAME_75" \
        ParameterKey=ServerState76,ParameterValue="$SERVER_STATE_76" \
        ParameterKey=RecordName76,ParameterValue="$RECORD_NAME_76" \
        ParameterKey=ServerState77,ParameterValue="$SERVER_STATE_77" \
        ParameterKey=RecordName77,ParameterValue="$RECORD_NAME_77" \
        ParameterKey=ServerState78,ParameterValue="$SERVER_STATE_78" \
        ParameterKey=RecordName78,ParameterValue="$RECORD_NAME_78" \
        ParameterKey=ServerState79,ParameterValue="$SERVER_STATE_79" \
        ParameterKey=RecordName79,ParameterValue="$RECORD_NAME_79" \
        ParameterKey=ServerState80,ParameterValue="$SERVER_STATE_80" \
        ParameterKey=RecordName80,ParameterValue="$RECORD_NAME_80" \
        ParameterKey=ServerState81,ParameterValue="$SERVER_STATE_81" \
        ParameterKey=RecordName81,ParameterValue="$RECORD_NAME_81" \
        ParameterKey=ServerState82,ParameterValue="$SERVER_STATE_82" \
        ParameterKey=RecordName82,ParameterValue="$RECORD_NAME_82" \
        ParameterKey=ServerState83,ParameterValue="$SERVER_STATE_83" \
        ParameterKey=RecordName83,ParameterValue="$RECORD_NAME_83" \
        ParameterKey=ServerState84,ParameterValue="$SERVER_STATE_84" \
        ParameterKey=RecordName84,ParameterValue="$RECORD_NAME_84" \
        ParameterKey=ServerState85,ParameterValue="$SERVER_STATE_85" \
        ParameterKey=RecordName85,ParameterValue="$RECORD_NAME_85" \
        ParameterKey=ServerState86,ParameterValue="$SERVER_STATE_86" \
        ParameterKey=RecordName86,ParameterValue="$RECORD_NAME_86" \
        ParameterKey=ServerState87,ParameterValue="$SERVER_STATE_87" \
        ParameterKey=RecordName87,ParameterValue="$RECORD_NAME_87" \
        ParameterKey=ServerState88,ParameterValue="$SERVER_STATE_88" \
        ParameterKey=RecordName88,ParameterValue="$RECORD_NAME_88" \
        ParameterKey=ServerState89,ParameterValue="$SERVER_STATE_89" \
        ParameterKey=RecordName89,ParameterValue="$RECORD_NAME_89" \
        ParameterKey=ServerState90,ParameterValue="$SERVER_STATE_90" \
        ParameterKey=RecordName90,ParameterValue="$RECORD_NAME_90" \
        ParameterKey=ServerState91,ParameterValue="$SERVER_STATE_91" \
        ParameterKey=RecordName91,ParameterValue="$RECORD_NAME_91" \
        ParameterKey=ServerState92,ParameterValue="$SERVER_STATE_92" \
        ParameterKey=RecordName92,ParameterValue="$RECORD_NAME_92" \
        ParameterKey=ServerState93,ParameterValue="$SERVER_STATE_93" \
        ParameterKey=RecordName93,ParameterValue="$RECORD_NAME_93" \
        ParameterKey=ServerState94,ParameterValue="$SERVER_STATE_94" \
        ParameterKey=RecordName94,ParameterValue="$RECORD_NAME_94" \
        --capabilities CAPABILITY_IAM
}

update_stack