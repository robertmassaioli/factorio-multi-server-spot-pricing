SERVERS=$1

cat <<HEADER_START
AWSTemplateFormatVersion: "2010-09-09"
Description: Factorio Spot Price Servers () via Docker / ECS
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
cat <<VARIABLE_PARAMETERS
  # ====================================================
  # ${i} - Server Specific Variables
  # ====================================================

  ServerState${i}:
    Type: String
    Description: "Running: A spot instance for Server ${i} will launch shortly after setting this parameter; your Factorio server should start within 5-10 minutes of changing this parameter (once UPDATE_IN_PROGRESS becomes UPDATE_COMPLETE). Stopped: Your spot instance (and thus Factorio container) will be terminated shortly after setting this parameter."
    Default: Stopped
    AllowedValues:
    - Running
    - Stopped

  RecordName${i}:
    Type: String
    Description: (Optional - An empty value disables this feature) If you have a hosted zone in Route 53 and wish to set a DNS record whenever your Factorio instance for server ${i} starts, supply the name of the record here (e.g. factorio.mydomain.com).
    Default: ''

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

for i in $(seq 1 $SERVERS)
do
cat <<ESSENTIAL_PARAMS
        - RecordName${i}
ESSENTIAL_PARAMS
done

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

  # ====================================================
  # EFS FOR PERSISTENT DATA
  # ====================================================

  Efs:
    Type: AWS::EFS::FileSystem
    DeletionPolicy: Retain
    Properties:
      LifecyclePolicies:
      - TransitionToIA: AFTER_7_DAYS
      - TransitionToPrimaryStorageClass: AFTER_1_ACCESS
      FileSystemTags:
      - Key: Name
        Value: !Sub "\${AWS::StackName}-fs"

  MountA:
    Type: AWS::EFS::MountTarget
    Properties:
      FileSystemId: !Ref Efs
      SecurityGroups:
      - !Ref EfsSg
      SubnetId: !Ref SubnetA

  MountB:
    Type: AWS::EFS::MountTarget
    Properties:
      FileSystemId: !Ref Efs
      SecurityGroups:
      - !Ref EfsSg
      SubnetId: !Ref SubnetB

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


  LambdaSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for Lambda function
      VpcId: !Ref Vpc
      SecurityGroupEgress:
        - IpProtocol: tcp
          FromPort: 2049
          ToPort: 2049
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

  CloudFormationVPCEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      ServiceName: !Sub "com.amazonaws.\${AWS::Region}.cloudformation"
      VpcId: !Ref Vpc
      PrivateDnsEnabled: true
      VpcEndpointType: Interface
      SubnetIds:
        - !Ref SubnetA
        - !Ref SubnetB
      SecurityGroupIds:
        - !Ref LambdaSecurityGroup

  S3VPCEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      ServiceName: !Sub "com.amazonaws.\${AWS::Region}.s3"
      VpcId: !Ref Vpc
      RouteTableIds:
        - !Ref RouteTable
      PolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal: "*"
            Action:
              - "s3:*"
            Resource: "*"

  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole
        - arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess
      Policies:
        - PolicyName: EfsAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - elasticfilesystem:ClientMount
                  - elasticfilesystem:ClientWrite
                Resource: !GetAtt Efs.Arn
        - PolicyName: LambdaVPCAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - ec2:CreateNetworkInterface
                  - ec2:DescribeNetworkInterfaces
                  - ec2:DeleteNetworkInterface
                Resource: '*'
        - PolicyName: CloudFormationAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - cloudformation:SignalResource
                Resource: '*'

  CreateDirectoriesLambdaPermission:
    Type: AWS::Lambda::Permission
    Properties:
      FunctionName: !GetAtt CreateDirectoriesFunction.Arn
      Action: lambda:InvokeFunction
      Principal: cloudformation.amazonaws.com

  CreateDirectoriesFunction:
    Type: AWS::Lambda::Function
    Properties:
      Handler: index.handler
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        ZipFile: |
          import cfnresponse
          import boto3
          import os
          import errno
          import logging

          # Set up logging
          logger = logging.getLogger()
          logger.setLevel(logging.INFO)

          def handler(event, context):
              logger.info(f"Event received: {event}")
              try:
                  if event['RequestType'] in ['Create', 'Update']:
                      efs_id = event['ResourceProperties']['EfsFileSystemId']
                      directory_names = event['ResourceProperties']['DirectoryNames']

                      logger.info(f"EFS ID: {efs_id}")
                      logger.info(f"Directories to create: {directory_names}")

                      # Mount EFS
                      mount_path = '/mnt/efs'
                      logger.info(f"Creating mount path: {mount_path}")
                      os.makedirs(mount_path, exist_ok=True)

                      mount_command = f'mount -t nfs4 -o rw,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport {efs_id}.efs.{os.environ["AWS_REGION"]}.amazonaws.com:/ {mount_path}'
                      logger.info(f"Mounting EFS with command: {mount_command}")
                      mount_result = os.system(mount_command)
                      logger.info(f"Mount command result: {mount_result}")

                      # Create directories
                      created_dirs = []
                      for directory_name in directory_names:
                          dir_path = os.path.join(mount_path, directory_name)
                          logger.info(f"Attempting to create directory: {dir_path}")
                          try:
                              os.makedirs(dir_path)
                              created_dirs.append(directory_name)
                              logger.info(f"Successfully created directory: {dir_path}")
                          except OSError as exc:
                              if exc.errno != errno.EEXIST:
                                  logger.error(f"Failed to create directory {dir_path}: {exc}")
                                  raise
                              else:
                                  logger.warning(f"Directory already exists: {dir_path}")

                      # Unmount EFS
                      logger.info(f"Unmounting EFS from {mount_path}")
                      unmount_result = os.system(f'umount {mount_path}')
                      logger.info(f"Unmount command result: {unmount_result}")

                      success_message = f'Directories created successfully: {", ".join(created_dirs)}'
                      logger.info(success_message)
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, {'Message': success_message})
                  elif event['RequestType'] == 'Delete':
                      logger.info("Delete request received. No action taken.")
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, {'Message': 'Delete request acknowledged'})
              except Exception as e:
                  logger.error(f"Error occurred: {str(e)}", exc_info=True)
                  cfnresponse.send(event, context, cfnresponse.FAILED, {'Error': str(e)})

      Runtime: python3.8
      Timeout: 300
      VpcConfig:
        SecurityGroupIds:
          - !Ref LambdaSecurityGroup
        SubnetIds:
          - !Ref SubnetA
          - !Ref SubnetB

  CreateEFSSubdirectories:
    Type: Custom::CreateDirectories
    DependsOn:
      - MountA
      - MountB
    Properties:
      ServiceToken: !GetAtt CreateDirectoriesFunction.Arn
      EfsFileSystemId: !Ref Efs
      DirectoryNames:
RESOURCES_START

for i in $(seq 1 $SERVERS)
do
cat <<SUB_DIRECTORIES_EFS
        - factorio-${i}
SUB_DIRECTORIES_EFS
done

cat <<EC2_COMMON_RESOURCES

  # ====================================================
  # EC2 Common
  # ====================================================

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

  EcsCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub "\${AWS::StackName}-cluster"

EC2_COMMON_RESOURCES

for i in $(seq 1 $SERVERS)
do
cat <<PARAM_BLOCK
  # ====================================================
  # INSTANCE CONFIG - ${1}
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
    - MountA
    - MountB
    - CreateEFSSubdirectories
    Properties:
      Volumes:
      - Name: !Sub "\${AWS::StackName}-factorio-${i}"
        EFSVolumeConfiguration:
          FilesystemId: !Ref Efs
          TransitEncryption: ENABLED
          RootDirectory: /factorio-${i}
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

  ExecuteLambdaRole:
    Type: AWS::IAM::Role
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
        - arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole
        - arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess
      Policies:
        - PolicyName: root
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: "Allow"
                Action: "route53:*"
                Resource: "*"
              - Effect: "Allow"
                Action: "ec2:DescribeInstance*"
                Resource: "*"
              - Effect: "Allow"
                Action:
                  - "elasticfilesystem:ClientMount"
                  - "elasticfilesystem:ClientWrite"
                  - "elasticfilesystem:DescribeMountTargets"
                Resource: "*"

  SetDNSRecordLambda:
    Type: "AWS::Lambda::Function"
    Condition: DnsConfigEnabled
    Properties:
      Environment:
        Variables:
          HostedZoneId: !Ref HostedZoneId
          ASGRecordMap: !Join [",", [
DNS_START

for i in $(seq 1 $SERVERS)
do
cat <<MAPPING_ASGS_TO_RECORD_NAMES
            !Sub "\${AutoScalingGroup${i}}:\${RecordName${i}}",
MAPPING_ASGS_TO_RECORD_NAMES

done

cat <<DNS_MID_1
          ]]
      Code:
        ZipFile: |
          import boto3
          import os

          def handler(event, context):
            asg_name = event['detail']['AutoScalingGroupName']

            # Parse the ASG to record name mapping
            asg_record_map = dict(item.split(':') for item in os.environ['ASGRecordMap'].split(','))

            # Get the record name for the current ASG
            record_name = asg_record_map.get(asg_name)
            if not record_name:
              raise ValueError(f"No record name mapping found for ASG: {asg_name}")

            new_instance = boto3.resource('ec2').Instance(event['detail']['EC2InstanceId'])
            boto3.client('route53').change_resource_record_sets(
              HostedZoneId= os.environ['HostedZoneId'],
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
                                      'Value': new_instance.public_ip_address
                                  },
                              ]
                          }
                      },
                  ]
              })
      Description: Sets Route 53 DNS Record based on ASG name
      FunctionName: !Sub "\${AWS::StackName}-set-dns"
      Handler: index.handler
      MemorySize: 128
      Role: !GetAtt ExecuteLambdaRole.Arn
      Runtime: python3.12
      Timeout: 20

  LaunchEvent:
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
DNS_MID_1

for i in $(seq 1 $SERVERS)
do
cat <<MAPPING_ASGS_TO_RECORD_NAMES
          - !Ref AutoScalingGroup${i}
MAPPING_ASGS_TO_RECORD_NAMES

done

cat <<DNS_END
      Name: !Sub "\${AWS::StackName}-instance-launch"
      State: ENABLED
      Targets:
        - Arn: !GetAtt SetDNSRecordLambda.Arn
          Id: !Sub "\${AWS::StackName}-set-dns"

  LaunchEventLambdaPermission:
    Type: AWS::Lambda::Permission
    Condition: DnsConfigEnabled
    Properties:
      Action: lambda:InvokeFunction
      FunctionName: !GetAtt SetDNSRecordLambda.Arn
      Principal: events.amazonaws.com
      SourceArn: !GetAtt LaunchEvent.Arn
DNS_END
