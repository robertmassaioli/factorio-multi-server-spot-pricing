SERVERS=$1

cat <<HEADER_START
AWSTemplateFormatVersion: "2010-09-09"
Description: Factorio Spot Price Servers (${SERVERS}) via Docker / ECS
Parameters:

  ECSAMI:
    Description: AWS ECS AMI ID
    Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>
    Default: /aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id

  FactorioImageTag:
    Type: String
    Description: "(Examples include latest, stable, 0.17, 0.17.33) Refer to tag descriptions available here: https://hub.docker.com/r/factoriotools/factorio/)"
    Default: latest

  InstancePurchaseMode:
    Type: String
    Description: "Spot: Much cheaper, but your instance might restart during gameplay with a few minutes of unsaved gameplay lost. On Demand: Instance will be created in on-demand mode. More expensive, but your gameplay is unlikely to be interrupted by the server going down."
    Default: "Spot"
    AllowedValues:
    - "On Demand"
    - "Spot"

  InstanceType:
    Type: String
    Description: "Spot: While m6a.large is a good instance type, you should leave this blank to get the best value instance for the provided specs. Override at your discretion: https://aws.amazon.com/ec2/instance-types/. On Demand: You must specify this. "
    Default: ""

  SpotPrice:
    Type: String
    Description: "Spot: the max cents/hr to pay for spot instance. On Demand: Ignored"
    Default: "0.05"

  SpotMinMemoryMiB:
    Type: Number
    Description: "Spot: the minimum desired memory for your instance. On Demand: Ignored"
    Default: 2048

  SpotMinVCpuCount:
    Type: Number
    Description: "Spot: the minimum desired VCPUs for your instance. On Demand: Ignored"
    Default: 2

  KeyPairName:
    Type: String
    Description: (Optional - An empty value disables this feature)
    Default: ''

  YourIp:
    Type: String
    Description: (Optional - An empty value disables this feature)
    Default: ''

  HostedZoneId:
    Type: String
    Description: (Optional - An empty value disables this feature) If you have a hosted zone in Route 53 and wish to set a DNS record whenever your Factorio instance starts, supply the hosted zone ID here.
    Default: ''

  SubDomainPrefix:
    Type: String
    Description: The default Route Name prefix that will be given to your servers if a HostName is defined. (e.g. factorio-1, factorio-2, etc.)
    Default: 'factorio-'

  EnableRcon:
    Type: String
    Description: Refer to https://hub.docker.com/r/factoriotools/factorio/ for further RCON configuration details. This parameter simply opens / closes the port on the security group.
    Default: false
    AllowedValues:
    - true
    - false

  UpdateModsOnStart:
    Type: String
    Description: Refer to https://hub.docker.com/r/factoriotools/factorio/ for further configuration details.
    Default: false
    AllowedValues:
    - true
    - false

HEADER_START

for i in $(seq 1 $SERVERS)
do
DEFAULT_STATE="Stopped"
if [ "x$i" == "x1" ];
then
  DEFAULT_STATE="Running"
fi

cat <<VARIABLE_PARAMETERS
  # ====================================================
  # ${i} - Server Specific Variables
  # ====================================================

  ServerState${i}:
    Type: String
    Description: "Running: A spot instance for Server ${i} will launch shortly after setting this parameter; your Factorio server should start within 5-10 minutes of changing this parameter (once UPDATE_IN_PROGRESS becomes UPDATE_COMPLETE). Stopped: Your spot instance (and thus Factorio container) will be terminated shortly after setting this parameter."
    Default: ${DEFAULT_STATE}
    AllowedValues:
    - Running
    - Stopped

VARIABLE_PARAMETERS
done

cat <<METADATA_START
Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups:
      - Label:
          default: Essential Configuration
        Parameters:
        - FactorioImageTag
        - EnableRcon
        - UpdateModsOnStart
METADATA_START

for i in $(seq 1 $SERVERS)
do
cat <<ESSENTIAL_PARAMS
        - ServerState${i}
ESSENTIAL_PARAMS
done

cat <<METADATA_MID_1
      - Label:
          default: Instance Configuration
        Parameters:
        - InstancePurchaseMode
        - InstanceType
        - SpotPrice
        - SpotMinMemoryMiB
        - SpotMinVCpuCount
      - Label:
          default: Remote Access (SSH) Configuration (Optional)
        Parameters:
        - KeyPairName
        - YourIp
      - Label:
          default: DNS Configuration (Optional)
        Parameters:
        - HostedZoneId
METADATA_MID_1

cat <<PARAMETER_LABELS_START
    ParameterLabels:
      FactorioImageTag:
        default: "Which version of Factorio do you want to launch?"
      InstanceType:
        default: "Which instance type? You must make sure this is available in your region! https://aws.amazon.com/ec2/pricing/on-demand/"
      KeyPairName:
        default: "If you wish to access the instance via SSH, select a Key Pair to use. https://console.aws.amazon.com/ec2/v2/home?#KeyPairs:sort=keyName"
      YourIp:
        default: "If you wish to access the instance via SSH, provide your public IP address."
      HostedZoneId:
        default: "If you have a hosted zone in Route 53 and wish to update a DNS record whenever your Factorio instance starts, supply the hosted zone ID here."
      EnableRcon:
        default: "Do you wish to enable RCON?"
      UpdateModsOnStart:
        default: "Do you wish to update your mods on container start"
PARAMETER_LABELS_START

for i in $(seq 1 $SERVERS)
do
cat <<VAR_PARAMATER_LABEL
      ServerState${i}:
        default: "Update this parameter to shut down / start up your Factorio server ${i} as required to save on cost. Takes a few minutes to take effect."
      RecordName${i}:
        default: "If you have a hosted zone in Route 53 and wish to set a DNS record whenever your Factorio instance server ${i} starts, supply a record name here (e.g. factorio.mydomain.com)."
VAR_PARAMATER_LABEL
done

cat <<CONDITIONS_START
Conditions:
  KeyPairNameProvided: !Not [ !Equals [ !Ref KeyPairName, '' ] ]
  IpAddressProvided: !Not [ !Equals [ !Ref YourIp, '' ] ]
  DoEnableRcon: !Equals [ !Ref EnableRcon, 'true' ]
  DnsConfigEnabled: !Not [ !Equals [ !Ref HostedZoneId, '' ] ]
  UsingSpotInstance: !Equals [ !Ref InstancePurchaseMode, 'Spot' ]
  InstanceTypeProvided: !Not [ !Equals [ !Ref InstanceType, '' ] ]
CONDITIONS_START

# You can't have more than 20 conditions in an or block
# Generate the condition
# condition="  DnsConfigEnabled: !And\n"
# condition+="  - !Not [!Equals [!Ref HostedZoneId, '']]\n"

# condition+="  - !Or\n"

# for i in $(seq 1 $SERVERS); do
#     condition+="    - !Not [!Equals [!Ref RecordName$i, '']]\n"
# done

# Output the condition
# echo -e "$condition"

cat <<MAPPINGS_SECTION

Mappings:
  ServerState:
    Running:
      DesiredCapacity: 1
    Stopped:
      DesiredCapacity: 0

MAPPINGS_SECTION

cat <<RESOURCES_START
Resources:

  # ====================================================
  # BASIC VPC
  # ====================================================

  Vpc:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.100.0.0/24
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Join
            - '-'
            - [!Ref 'AWS::StackName', 'vpc']

  SubnetA:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select
      - 0
      - !GetAZs
        Ref: 'AWS::Region'
      CidrBlock: !Select [ 0, !Cidr [ 10.100.0.0/24, 2, 7 ] ]
      VpcId: !Ref Vpc
      MapPublicIpOnLaunch: true

  SubnetB:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: !Select
      - 1
      - !GetAZs
        Ref: 'AWS::Region'
      CidrBlock: !Select [ 1, !Cidr [ 10.100.0.0/24, 2, 7 ] ]
      VpcId: !Ref Vpc
      MapPublicIpOnLaunch: true

  SubnetARoute:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable
      SubnetId: !Ref SubnetA

  SubnetBRoute:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable
      SubnetId: !Ref SubnetB

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties: {}

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref Vpc

  RouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref Vpc

  Route:
    Type: AWS::EC2::Route
    Properties:
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway
      RouteTableId: !Ref RouteTable

  EfsSg:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub "\${AWS::StackName}-efs"
      GroupDescription: !Sub "\${AWS::StackName}-efs"
      SecurityGroupIngress:
      - FromPort: 2049
        ToPort: 2049
        IpProtocol: tcp
        SourceSecurityGroupId: !Ref Ec2Sg
      VpcId: !Ref Vpc

  Ec2Sg:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub "\${AWS::StackName}-ec2"
      GroupDescription: !Sub "\${AWS::StackName}-ec2"
      SecurityGroupIngress:
      - !If
        - IpAddressProvided
        - FromPort: 22
          ToPort: 22
          IpProtocol: tcp
          CidrIp: !Sub "\${YourIp}/32"
        - !Ref 'AWS::NoValue'
      - FromPort: 34197
        ToPort: 34197
        IpProtocol: udp
        CidrIp: 0.0.0.0/0
      - !If
        - DoEnableRcon
        - FromPort: 27015
          ToPort: 27015
          IpProtocol: tcp
          CidrIp: 0.0.0.0/0
        - !Ref 'AWS::NoValue'
      VpcId: !Ref Vpc

  # ====================================================
  # Common Resources
  # ====================================================

  InstanceRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Principal:
            Service:
            - ec2.amazonaws.com
          Action:
          - sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
      Policies:
        - PolicyName: root
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: "Allow"
                Action: "route53:*"
                Resource: "*"

  InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Roles:
        - !Ref InstanceRole

  EcsCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub "\${AWS::StackName}-cluster"

  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: !Sub \${AWS::StackName}-launch-template
      LaunchTemplateData:
        IamInstanceProfile:
          Arn: !GetAtt InstanceProfile.Arn
        ImageId: !Ref ECSAMI
        SecurityGroupIds:
        - !Ref Ec2Sg
        KeyName:
          !If [ KeyPairNameProvided, !Ref KeyPairName, !Ref 'AWS::NoValue' ]
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash -xe
            echo ECS_CLUSTER=\${EcsCluster} >> /etc/ecs/ecs.config

RESOURCES_START

for i in $(seq 1 $SERVERS)
do
cat <<PARAM_BLOCK
  # ====================================================
  # ${i} - EFS FOR PERSISTENT DATA
  # ====================================================

  Efs${i}:
    Type: AWS::EFS::FileSystem
    DeletionPolicy: Retain
    Properties:
      LifecyclePolicies:
      - TransitionToIA: AFTER_7_DAYS
      - TransitionToPrimaryStorageClass: AFTER_1_ACCESS
      FileSystemTags:
      - Key: Name
        Value: !Sub "\${AWS::StackName}-fs-${i}"

  Mount${i}A:
    Type: AWS::EFS::MountTarget
    Properties:
      FileSystemId: !Ref Efs${i}
      SecurityGroups:
      - !Ref EfsSg
      SubnetId: !Ref SubnetA

  Mount${i}B:
    Type: AWS::EFS::MountTarget
    Properties:
      FileSystemId: !Ref Efs${i}
      SecurityGroups:
      - !Ref EfsSg
      SubnetId: !Ref SubnetB

  # ====================================================
  # ${i} - INSTANCE CONFIG
  # ====================================================

  AutoScalingGroup${i}:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AutoScalingGroupName: !Sub "\${AWS::StackName}-asg-${i}"
      DesiredCapacity: !FindInMap [ ServerState, !Ref ServerState${i}, DesiredCapacity ]
      MixedInstancesPolicy:
        InstancesDistribution:
          OnDemandPercentageAboveBaseCapacity:
            !If [ UsingSpotInstance, 0, 100 ]
          SpotAllocationStrategy: lowest-price
          SpotMaxPrice:
            !If [ UsingSpotInstance, !Ref SpotPrice, !Ref AWS::NoValue ]
        LaunchTemplate:
          LaunchTemplateSpecification:
            LaunchTemplateId: !Ref LaunchTemplate
            Version: !GetAtt LaunchTemplate.LatestVersionNumber
          Overrides:
           - Fn::If:
             - InstanceTypeProvided
             - InstanceType: !Ref InstanceType
             - InstanceRequirements:
                 MemoryMiB:
                   Min: !Ref SpotMinMemoryMiB
                 VCpuCount:
                   Min: !Ref SpotMinVCpuCount
      MaxSize: !FindInMap [ ServerState, !Ref ServerState${i}, DesiredCapacity ]
      MinSize: !FindInMap [ ServerState, !Ref ServerState${i}, DesiredCapacity ]
      VPCZoneIdentifier:
        - !Ref SubnetA
        - !Ref SubnetB

  EcsService${i}:
    Type: AWS::ECS::Service
    Properties:
      Cluster: !Ref EcsCluster
      DesiredCount: !FindInMap [ ServerState, !Ref ServerState${i}, DesiredCapacity ]
      ServiceName: !Sub "\${AWS::StackName}-ecs-service-${i}"
      TaskDefinition: !Ref EcsTask${i}
      DeploymentConfiguration:
        MaximumPercent: 100
        MinimumHealthyPercent: 0

  EcsTask${i}:
    Type: AWS::ECS::TaskDefinition
    DependsOn:
    - Mount${i}A
    - Mount${i}B
    Properties:
      Volumes:
      - Name: !Sub "\${AWS::StackName}-factorio-${i}"
        EFSVolumeConfiguration:
          FilesystemId: !Ref Efs${i}
          TransitEncryption: ENABLED
      ContainerDefinitions:
        - Name: factorio
          MemoryReservation: 1024
          Image: !Sub "factoriotools/factorio:\${FactorioImageTag}"
          PortMappings:
          - ContainerPort: 34197
            HostPort: 34197
            Protocol: udp
          - ContainerPort: 27015
            HostPort: 27015
            Protocol: tcp
          MountPoints:
          - ContainerPath: /factorio
            SourceVolume: !Sub "\${AWS::StackName}-factorio-${i}"
            ReadOnly: false
          Environment:
          - Name: UPDATE_MODS_ON_START
            Value: !Sub "\${UpdateModsOnStart}"

PARAM_BLOCK
done

cat <<DNS_START
  # ====================================================
  # SET DNS RECORD - For all ASGs and EC2 instances
  # ====================================================

  SetDNSRecordLambdaRole:
    Type: AWS::IAM::Role
    Condition: DnsConfigEnabled
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Principal:
            Service:
            - lambda.amazonaws.com
          Action:
          - sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: root
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: "Allow"
                Action:
                  - "route53:*"
                  - "route53:ListHostedZones"
                Resource: "*"
              - Effect: "Allow"
                Action: "ec2:DescribeInstance*"
                Resource: "*"
              - Effect: "Allow"
                Action:
                  - "s3:GetObject"
                  - "s3:ListBucket"
                Resource:
                  - !Sub "arn:aws:s3:::\${S3ConfigBucket}"
                  - !Sub "arn:aws:s3:::\${S3ConfigBucket}/*"

  S3ConfigBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "\${AWS::StackName}-config"
      VersioningConfiguration:
        Status: Enabled
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

  SetDNSRecordLambda:
    Type: "AWS::Lambda::Function"
    Condition: DnsConfigEnabled
    Properties:
      Environment:
        Variables:
          HostedZoneId: !Ref HostedZoneId
          SubDomainPrefix: !Ref SubDomainPrefix
          BaseDomain: !Ref BaseDomain
          S3ConfigBucket: !Ref S3ConfigBucket
      Code:
        ZipFile: |
          import boto3
          import os
          import json
          import re
          import logging

          # Set up logging
          logger = logging.getLogger()
          logger.setLevel(logging.INFO)

          def get_domain_from_hosted_zone_id(hosted_zone_id):
              logger.info(f"Retrieving domain name for Hosted Zone ID: {hosted_zone_id}")
              route53 = boto3.client('route53')
              try:
                  response = route53.get_hosted_zone(Id=hosted_zone_id)
                  domain = response['HostedZone']['Name'].rstrip('.')
                  logger.info(f"Retrieved domain name: {domain}")
                  return domain
              except Exception as e:
                  logger.error(f"Error retrieving domain name: {str(e)}")
                  raise

          def handler(event, context):
              logger.info(f"Lambda function invoked with event: {json.dumps(event)}")

              asg_name = event['detail']['AutoScalingGroupName']
              logger.info(f"Processing Auto Scaling Group: {asg_name}")

              # Extract the number from the ASG name
              asg_number_match = re.search(r'-(\d+)$', asg_name)
              if not asg_number_match:
                  error_msg = f"Invalid ASG name format: {asg_name}"
                  logger.error(error_msg)
                  raise ValueError(error_msg)

              asg_number = asg_number_match.group(1)
              logger.info(f"Extracted ASG number: {asg_number}")

              # Get the base domain from the Hosted Zone Id
              hosted_zone_id = os.environ['HostedZoneId']
              base_domain = get_domain_from_hosted_zone_id(hosted_zone_id)

              # Generate the default domain name
              sub_domain_prefix = os.environ['SubDomainPrefix']
              default_domain = f"{sub_domain_prefix}-{asg_number}.{base_domain}"
              logger.info(f"Generated default domain name: {default_domain}")

              # Check for override config
              s3 = boto3.client('s3')
              s3_config_bucket = os.environ['S3ConfigBucket']
              logger.info(f"Checking for config override in S3 bucket: {s3_config_bucket}")
              try:
                  config_file = s3.get_object(Bucket=s3_config_bucket, Key='factorio.config.json')
                  config_content = config_file['Body'].read().decode('utf-8')
                  config = json.loads(config_content)
                  logger.info(f"Successfully loaded config from S3: {json.dumps(config)}")
                  record_name = config.get(asg_name, default_domain)
                  logger.info(f"Using record name from config: {record_name}")
              except s3.exceptions.NoSuchKey:
                  logger.info("No config file found in S3, using default domain")
                  record_name = default_domain
              except Exception as e:
                  logger.error(f"Error reading config file: {str(e)}")
                  logger.info("Falling back to default domain")
                  record_name = default_domain

              # Get the new EC2 instance details
              ec2_instance_id = event['detail']['EC2InstanceId']
              logger.info(f"Retrieving details for EC2 instance: {ec2_instance_id}")
              new_instance = boto3.resource('ec2').Instance(ec2_instance_id)
              public_ip = new_instance.public_ip_address
              logger.info(f"Retrieved public IP for instance: {public_ip}")

              # Update Route 53 record
              logger.info(f"Updating Route 53 record for {record_name} to point to {public_ip}")
              route53 = boto3.client('route53')
              try:
                  response = route53.change_resource_record_sets(
                      HostedZoneId=hosted_zone_id,
                      ChangeBatch={
                          'Comment': f'Updating DNS for {asg_name}',
                          'Changes': [
                              {
                                  'Action': 'UPSERT',
                                  'ResourceRecordSet': {
                                      'Name': record_name,
                                      'Type': 'A',
                                      'TTL': 60,
                                      'ResourceRecords': [
                                          {
                                              'Value': public_ip
                                          },
                                      ]
                                  }
                              },
                          ]
                      })
                  logger.info(f"Successfully updated Route 53 record. Change Info: {json.dumps(response['ChangeInfo'])}")
              except Exception as e:
                  logger.error(f"Error updating Route 53 record: {str(e)}")
                  raise

              logger.info("Lambda function execution completed successfully")
      Description: Sets Route 53 DNS Record based on ASG name
      FunctionName: !Sub "\${AWS::StackName}-set-dns"
      Handler: index.handler
      MemorySize: 128
      Role: !GetAtt SetDNSRecordLambdaRole.Arn
      Runtime: python3.12
      Timeout: 20

DNS_START

ASG_COUNT=$SERVERS

# Set the bucket size
BUCKET_SIZE=20

# Function to generate YAML for a single event rule
# Function to generate YAML for a single event rule
generate_event_rule() {
    local start=$1
    local end=$2
    local rule_number=$3

    cat << EOF
  LaunchEvent${rule_number}:
    Type: AWS::Events::Rule
    Condition: DnsConfigEnabled
    Properties:
      EventPattern:
        source:
        - aws.autoscaling
        detail-type:
        - EC2 Instance Launch Successful
        detail:
          AutoScalingGroupName:
EOF
    for asg_num in $(seq $start $end); do
        echo "          - !Ref AutoScalingGroup${asg_num}"
    done
    cat << EOF
      Name: !Sub "\${AWS::StackName}-instance-launch-${rule_number}"
      State: ENABLED
      Targets:
        - Arn: !GetAtt SetDNSRecordLambda.Arn
          Id: !Sub "\${AWS::StackName}-set-dns"

EOF
}

# Function to generate YAML for a Lambda permission
generate_lambda_permission() {
    local rule_number=$1

    cat << EOF
  LaunchEventLambdaPermission${rule_number}:
    Type: AWS::Lambda::Permission
    Condition: DnsConfigEnabled
    Properties:
      Action: lambda:InvokeFunction
      FunctionName: !GetAtt SetDNSRecordLambda.Arn
      Principal: events.amazonaws.com
      SourceArn: !GetAtt LaunchEvent${rule_number}.Arn

EOF
}

# Calculate the number of rules needed
rule_count=$(( ($ASG_COUNT + $BUCKET_SIZE - 1) / $BUCKET_SIZE ))

# Generate YAML for each rule and corresponding permission
for i in $(seq 1 $rule_count); do
    start=$(( (i-1)*$BUCKET_SIZE + 1 ))
    end=$(( i*$BUCKET_SIZE < ASG_COUNT ? i*$BUCKET_SIZE : ASG_COUNT ))
    generate_event_rule $start $end $i
    generate_lambda_permission $i
done
