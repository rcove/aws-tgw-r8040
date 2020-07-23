# AWS CloudGuard IaaS Transit Gateway Demonstration 

Terraform scripts for transit gateway demonstration of CloudGuard in AWS\
Builds the complete environment with web and application servers, northbound and southbound e-w hubs\
See https://github.com/rcove/aws-tgw-r8040/blob/master/TGW%20POC%20v4.pdf for a diagram of the enviroment


---------------------------------------------------------------
One time preparation of the AWS account 
1.	Create or choose a ssh key-pair in the account for the DC you are using \
2.	Subscribe to the ELUAs for R80.40 BYOL gateway and management \
    R80.30 R80.40 management \
    https://aws.amazon.com/marketplace/pp/B07KSBV1MM?qid=1558349960795&sr=0-4&ref_=srh_res_product_title

    R80.30 R80.40 Gateway \
    https://aws.amazon.com/marketplace/pp/B07LB3YN9P?qid=1558349960795&sr=0-5&ref_=srh_res_product_title

3.	Create IAM access keys for the API login (for terraform) and save into credentials \
      shared_credentials_file = "~/.aws/credentials"  (linux) \
      shared_credentials_file = "%USERPROFILE%\.aws\credentials"  (windows)
      
4.  Ensure you have enough resources in the account, this script creates 6 VPC, 1 transit gateway and 12 instances (~20 cores), the cost for this will be a few dollars per hour, so it is recommended to destroy the resources when not using them, by default you can only create 5 VPC per region, log a resource request for more. 

----------------------------------------------------------------

One time preparation of the Terraform scripts 
Works with terraform v0.12.x 
1. Modify the variables.tf to suite your needs   
2. Delete Route53.tf if not needed and you dont have a route53 domain 
3. Run terraform init 

------------------------------------------------------------------

Solution Documentation   

The terraform script deploys these 3 CloudFormation templates with all the glue to configure them \
  template_url        = "https://s3.amazonaws.com/CloudFormationTemplate/management.json" \
  template_url        = "https://s3.amazonaws.com/CloudFormationTemplate/checkpoint-tgw-asg-master.yaml" \
  template_url        = "https://s3.amazonaws.com/CloudFormationTemplate/autoscale.json" 

TGW documentation (Outbound cluster) \
https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_AWS_Transit_Gateway/html_frameset.htm

Autoscale Documentation (Inbound cluster) \
https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk112575   

CME (Cloud Management Extension) for CloudGuard \
https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk157492
CME Administration Guide \
https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CME/Content/Topics/Overview.htm

Modules  
  checkpoint.tf   - Contains the CFT for the gateways and manager\
  tgw.tf\
  instances.tf\
  subnets.tf\
  vpc.tf\
  routes.tf\
  external_nlb.tf\
  external_alb.tf\
  internal_lb.tf        - app1\
  internal_lb_app2.tf   - app2\
  variables.tf\
  route53.tf        - Optional, delete if R53 is not used  

-------------------------------------------------------------------

To run the script in terrraform  
    terraform init\
    terraform apply

You can Logon after about 30 mins to the manager via the windows based Check Point SmartDashboard R80.40

To remove the environment  
1. set the autoscale group to 0 instances for the outbound autoscale group, wait a few minutes to allow the site to site VPNs to be deleted then run\
    terraform destroy

Note: To use an existing manager; some modifications will be needed to terraform scripts and you will need to setup the CME and autoprov-cfg similar to the bootstrap

Please note that these scripts are for demonstration in labs and are not production validated, you should make sure you validate and test them if you plan on using them in anger

Based on Check Point IaaS R80.40, for the older version tested with R80.30 go to https://github.com/rcove/TGW 

*Troubleshooting*\
On the manager\ 
the logs for install are in\
first time install and startup script  /var/log/cloud-user-data.log\
CME run log - tail -f /var/log/CPcme/cme.log 

Sometimes you need to reset SIC, ssh to the gateway and run cpconfig, set the password to equal the one in the variables 