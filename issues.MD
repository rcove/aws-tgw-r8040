# These are the following issues and workarounds with the build 
They will get fixed at some point

The TGW gateway gets created and policy installs ok, then the script tries to reinstall and the CP GW stops responding to SIC, from then on it can no longer install policy.
I can still ssh to the gateway and unload the policy, then a new policy installs, and then I connect to other machines in my spokes via the vpns. But the connectivity problem comes back. 

1.	peer Mgmt vpc with inbound and outbound
2.	modifie the Mgmt RT to point to the peering for 10.20 and 10.30 (used to be TGW as next hop)
3.	I’ve deleted the TGW association to Mgmt VPC (and the CP-mgmt route table)
4.	Modified the Outbound RT route of 10.10/16 to point to the peering rather than TGW
5.	Modified the Inbound RT route of 10.10/16 to point to the peering rather than TGW
In that way there is no 10.10 route injected in the outbound gws by the bgp

The E-W traffic is bypassing the Gateways and going direct spoke to spoke.  
Fix: Set global settings / vpn / advanced / tick enable vpn directional match.  Reinstall 