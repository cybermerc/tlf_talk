Using Open Source to get above the security poverty line

Presented by Christopher Coffey RHCE, CISSP

Whoami -
- 20+ years in the *nix world.
- Worked in the security field (within both the DoD and the Banking sectors).
- Worked as Linux Admin/Engineer for various companies including last 7 years
  at Rackspace.

What is the security poverty line ?
- Loosely defined as an enity that does not have the technical ability and/or the financial
  resources to hire security expertise

Why is this a problem for the community as a whole?
-

What am I here to show?
 - What is a functional baseline for Linux security?
 - How we can help make it easy and cheap using open source solutions.

What is a functional Linux security baseline?
 - DISCLAIMER: This is a very opinionated baseline, every organization will need to decide
   The level that provides the comfort they need.
 - Proactive patching policy
   - at a minimum auto-patch on a set schedule
 - Non-root admin user.
   - If your logging in as root - YOUR DOING IT WRONG
   - Use of SSH key login at a minimum, optionally use key and password even better.
 - SSH Hardening
   - Disable Root login
   - Set users lists that is allowed to login via SSH
 - Log Monitoring
   - Setup remote log monitoring if possible
   - at a minimum use a tool such as logwatch to flag important issues and
     notify via email.


Walkthrough of Bash script/ Cloud-Init scripts
