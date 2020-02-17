-----
# POC Test Plan Outline TGW and Autoscale demo  
-----
Note: the ip and urls are for example only, you will discover your own in the AWS console
This is a *suggested* test plan  

Login to Manager gui xx.xx.xx.xx 
Create DC object with AWS using IAM  
Create rule 3.1 add destination Spoke2SG to any    
Publish and Install rules   
SSH to outbound gateway TGW admin@13.239.47.109  
[Expert@TGW-gw]# pep show user all # should see the DC Objects installed above  

Load balancers application test

From an Internet located browser 
ALB http://CP-TGW-External-ALB-1053723218.ap-southeast-2.elb.amazonaws.com  
ALB http://CP-TGW-External-ALB-1053723218.ap-southeast-2.elb.amazonaws.com/app1/  
ALB http://CP-TGW-External-ALB-1053723218.ap-southeast-2.elb.amazonaws.com/app2/  

NLB1 http://CP-TGW-External-NLB-06cd39b7de71ae2f.elb.ap-southeast-2.amazonaws.com  
NLB2 http://CP-TGW-External-NLB2-f4133e3dc2973229.elb.ap-southeast-2.amazonaws.com  
  
Test application server outbound and EW access
SSH to application server   

SSH to Jumpbox and create a private key, this will be used to ssh to app server (one time only)  
In this case, the jumpbox is one of the outbound Cloudguard gateways via external IP 
[Expert@outbound_gw:0]# cat > .ssh/myidentity  
-----BEGIN RSA PRIVATE KEY-----  
7YG4yHjNupzAoZ0YSTzGhsgPhPtpmnUIvbSGNf1C……  
…….-----END RSA PRIVATE KEY-----  
^d  
[Expert@outbound_gw:0]# chmod +600 .ssh/myidentity  
now ssh to application server (you can also ssh to web servers )
[Expert@gw:0]# ssh -i ~/.ssh/myidentity  ubuntu@10.120.176.xx  

Watch logs in SmartDahsboard GUI while accessing the load balancers as shown below     
Show rule 3.1 logging the packets  
Note: At present NLB cannot have a security group so CP cant see the tags (fixed in R80.40) 

This test shows E-W traffic inspection   
ubuntu@ip-10-120-176-115:~$ curl CP-TGW-Internal-NLB-xxxxxx.elb.amazonaws.com
Greetings! -----App1----- This is a web server in ap-southeast-2c!

ubuntu@ip-10-120-176-115:~$ curl CP-TGW-Internal-NLB-app2-xxxxxx.elb.amazonaws.com
Greetings! -----app2----- This is a web server in ap-southeast-2c!

ubuntu@ip-10-120-176-115:~$ curl google.com  
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">  

Testing threat
curl http://www.eicar.org/download/eicar_com.zip
curl http://sc1.checkpoint.com/za/images/threatwiki/pages/TestAntiBotBlade.html

Scale up both the gateway groups + see the lb groups get created in the policy
To scale up you can use either manual scale on ASG or use the SK article to apply a load script    
 
Application Control – setup policy + test so that you can see the urls in the logs   
https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk112575  

