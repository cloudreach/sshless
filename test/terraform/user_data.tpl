#!/bin/bash
hostname ${hostname}
sudo start amazon-ssm-agent
sudo stop amazon-ssm-agent
sudo amazon-ssm-agent -register -code "${activation_code}" -id "${activation_id}" -region "${region}"
sudo start amazon-ssm-agent
