# bind-secondary

Creates the OPS300 Lab 1 bind-secondary image and pushes it to the private
registry running at registry.assign.npatel355.300.ops:5000 using Jenkins.

## Pipeline
- Runs SCM polling on this repository and is executed on the SSH agent c1 (podman label) never on the controller.
- Uses podman build to create the image.
- Tags the image as `<build number>-<short commit SHA>`.
- Logs into the registry using Jenkins credentials registry-creds (no secrets in this repository).
- Registry logins are checked against Active Directory (group Registry Users); the Jenkins account is the AD user registry-ci.

## CVE Scanning decision
- Scans the created image with Trivy before pushing it.
- Retains the whole report (all severities) in the build artifact trivy-report.txt.
- Fails the build and does not push anything if there is a HIGH or CRITICAL CVE found that is patchable.
- Non-patchable CVEs are logged but will not cause a failed build, since the vulnerability cannot be fixed by re-building the image.
