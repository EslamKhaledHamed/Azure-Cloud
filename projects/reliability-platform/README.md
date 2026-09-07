\# Reliability Platform — Azure Infrastructure Project



A production-style Azure infrastructure project focused on building, validating, and documenting a reliable cloud environment using Infrastructure as Code.



\## Overview



This project demonstrates the deployment and validation of a small Azure infrastructure platform using:



\- Azure Resource Group

\- Azure Virtual Network

\- Subnet

\- Network Security Group

\- Network Interface

\- Windows Server 2022 Azure VM

\- Azure Storage Account

\- Private Blob Container

\- Azure RBAC

\- Azure CLI

\- PowerShell

\- Bicep / ARM Infrastructure as Code



The project was built as a hands-on reliability and cloud engineering exercise, with emphasis on repeatable infrastructure, security, validation, troubleshooting, and operational lifecycle management.



\## Architecture



```text

Azure Subscription

│

└── reliability-platform-rg

&#x20;   │

&#x20;   ├── reliability-vnet

&#x20;   │   │

&#x20;   │   └── app-subnet

&#x20;   │       │

&#x20;   │       ├── app-subnet-nsg

&#x20;   │       │

&#x20;   │       └── reliability-vm-nic

&#x20;   │               │

&#x20;   │               └── reliability-vm

&#x20;   │                   └── Windows Server 2022

&#x20;   │

&#x20;   └── Storage Account

&#x20;       │

&#x20;       └── documents

&#x20;           └── azure-test.txt

