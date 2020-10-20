# These are the following issues and workarounds with the build 
These issues are known and will get fixed at some point

Upgrade to R81 is pending

* The E-W traffic is bypassing the Gateways and going direct spoke to spoke
  * Workaround: 
  * Set global settings / vpn / advanced / tick enable vpn directional match.  Reinstall
  * Note: sometimes it E-W works without this setting, will be re-tested in R81 

* Manager does not fully build, user script fails to update and install CME, cant see and gateways in the manager
  * Workaround:
  * There is a new autoupdater that doesnt always work as expected for CME 
  * SSH to manager after the build and install the latest CME as per the Check Point article sk157492
  * Check that "autoprov-cfg -v" works
  * edit /etc/cloud-setup.sh (on the manager instance) and remove update commands (first lines), run this script again, it should setup manager properly now 
  
