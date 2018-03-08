#!/bin/bash


if [[ $1 == "apply" ]]; then
  set -x
  terraform init
  terraform apply -auto-approve=true

elif [[ $1 == "delete" ]] || [[ $1 == "destroy" ]]; then
  set -x
  terraform destroy  -force
  set +x
  ONPREMASSC=$(aws ssm describe-instance-information  --filters "Key=IamRole,Values=sshless-role-onprem" | jq -r '.InstanceInformationList[].InstanceId')

  for ASSOC in ${ONPREMASSC}; do
    echo "deregister-managed-instance: ${ASSOC}"
    aws ssm deregister-managed-instance --instance-id "${ASSOC}"
  done

elif [[ $1 == "web" ]] || [[ $1 == "app" ]]; then
  set -x
  sshless cmd -f tag:Role=$1 "wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document"

elif [[ $1 == "web-role" ]]; then

  SERVICEROLE=$(terraform output sshless-role-webrole)
  echo "executing SSHLess comand with service role with tag Role=web"
  set -x
  sshless --iam ${SERVICEROLE} cmd -f tag:Role=web hostname
  set +x

  echo "executing SSHLess comand with service role with tag Role=app"
  echo "expected to failed"
  set -x
  sshless --iam ${SERVICEROLE} cmd -f tag:Role=app hostname


elif [[ $1 == "legacy" ]]; then

  ONPREM=$(aws ssm describe-instance-information --instance-information-filter-list "key=ResourceType,valueSet=ManagedInstance" | jq -r '.InstanceInformationList[] | select(.Name | contains("legacy")) | .InstanceId ' |  tr '\n' ',' | sed 's/.$//')
  echo "Onprem: Query using ID (Tags not available) ID: ${ONPREM}"
  set -x
  sshless cmd -i ${ONPREM} hostname

elif [[ $1 == "azure" ]]; then

  AZURE=$(aws ssm describe-instance-information --instance-information-filter-list "key=ResourceType,valueSet=ManagedInstance" | jq -r '.InstanceInformationList[] | select(.Name | contains("azure")) | .InstanceId ' |  tr '\n' ',' | sed 's/.$//')
  echo "Azure: Query using ID (Tags not available) ID: ${AZURE}"
  set -x
  sshless cmd -i ${AZURE} hostname

elif [[ $1 == "parameter" ]]; then
  echo "EC2 reading Parameter Store"
  set -x
  sshless cmd -f tag:Purpose=sshless 'echo "hostname: $(hostname) - SSM Param: {{ssm:example.parameter}}"'
  set +x

  echo "OnPrem reading Parameter Store"
  ONPREM=$(aws ssm describe-instance-information --instance-information-filter-list "key=ResourceType,valueSet=ManagedInstance" | jq -r '.InstanceInformationList[] | select(.Name | contains("legacy")) | .InstanceId ' |  tr '\n' ',' | sed 's/.$//')
  echo "Query using ID (Tags not available) ID: ${ONPREM}"
  set -x
  sshless cmd -i ${ONPREM} 'echo "hostname: $(hostname) - SSM Param: {{ssm:example.parameter}}"'

  set +x
  echo "Azure reading Parameter Store"
  AZURE=$(aws ssm describe-instance-information --instance-information-filter-list "key=ResourceType,valueSet=ManagedInstance" | jq -r '.InstanceInformationList[] | select(.Name | contains("azure")) | .InstanceId ' |  tr '\n' ',' | sed 's/.$//')
  echo "Azure: Query using ID (Tags not available) ID: ${AZURE}"
  set -x
  sshless cmd -i ${AZURE} 'echo "hostname: $(hostname) - SSM Param: {{ssm:example.parameter}}"'



else
  echo "MISSING Action: ./run.sh apply | destroy | web | app | web-role | legacy | parameter"
fi
