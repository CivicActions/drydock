#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -lt 3 || "${1:-}" != "auto" && "${1:-}" != "manual" ]]; then
    echo "Run OpenSCAP on Docker RHEL 7 and CentOS 7 images"
    echo
    echo "There are 2 ways to use this tool:"
    echo "Automatic: Provide exactly 3 arguments: auto [imagename:tag] [profileId]."
    echo "  e.g. 'auto centos:7 xccdf_org.ssgproject.content_profile_stig-rhel7-disa'"
    echo "  The second argument is the image name/tag to evaluate. The final argument is"
    echo "  the XCCDF profile Id to use (run 'manual info' to see the available profiles)."
    echo "  This will cause both XCCDF profile and OPAL CVE evaluations to be completed."
    echo "  Reports will be saved to the /workspace directory, mount a directory to that location"
    echo "  if you wish to retain them. If /workspace/tailoring.xml exists then it will be used to"
    echo "  tailor the XCCDF eval."
    echo "  Both results will be evaluated and exit code will be 10 if there are fails and 0 if none."
    echo
    echo "Manual: Provide a 'manual' argument, an image name to evaluate, then oscap parameters:"
    echo "  e.g. 'manual centos:7 oval eval /usr/share/xml/scap/ssg/content/ssg-rhel7-oval.xml'"
    echo "  If you want to reference tailoring files and/or reports you can mount an"
    echo "  additional directory and reference that in your command."
    echo
    echo "Notes:"
    echo "  Mount /var/run/docker.sock from the host to this container, (you should not need --privileged=true)."
    echo "  If you are scanning a remote image, you will need to pull the image on the host first."
    exit 1
fi

if [ -r "/var/run/docker.sock" ]; then
    echo "Mount /var/run/docker.sock from the host to this container, (you should not need --privileged=true)."
fi

echo "Unpacking the image"
docker-companion unpack "$2" /mnt

if [ "$1" == "auto" ]; then
    echo "Running automatic evaluations"
    if [ ! -d "/workspace" ]; then
        mkdir /workspace
    fi
    OPAL_REPORT='--results /workspace/oval-results.xml --report /workspace/oval-report.html'
    XCCDF_REPORT='--results-arf /workspace/ssg-results-arf.xml --report /workspace/ssg-report.html'
    XCCDF_TAILORING=
    if [ -r "/workspace/tailoring.xml" ]; then
        XCCDF_TAILORING='--tailoring-file /workspace/tailoring.xml'
    fi
    OS=rhel7
    if [ -f "/mnt/etc/centos-release" ]; then
        OS=centos7
    fi
    echo "Running XCCDF evaluation"
    # We enable command echo for all oscap commands for transparency/reproducibility
    set -x
    # shellcheck disable=SC2086
    oscap-chroot /mnt xccdf eval --fetch-remote-resources --profile "$3" ${XCCDF_REPORT} ${XCCDF_TAILORING} "/usr/share/xml/scap/ssg/content/ssg-${OS}-ds.xml" || true
    set +x
    echo "Fetching latest OVAL content"
    curl -Ls https://www.redhat.com/security/data/oval/com.redhat.rhsa-RHEL7.xml.bz2 | bzip2 -d -c > /tmp/oval.xml
    echo "Running OVAL evaluation"
    # We enable command echo for all oscap commands for transparency/reproducibility
    set -x
    # shellcheck disable=SC2086
    oscap-chroot /mnt oval eval ${OPAL_REPORT} /tmp/oval.xml || true
    set +x
    echo "Checking results"
    # Count any non-false OVAL results as fails:
    OVAL=$(xpath  -e 'count(/oval_results/results/system/definitions/definition[@result!="false"])' /workspace/oval-results.xml 2> /dev/null)
    echo "OVAL fails: $OVAL"
    # Count any selected, applicable, non-pass XCCDF results as fails:
    XCCDF=$(xpath -q -e 'count(/arf:asset-report-collection/arf:reports/arf:report[@id="xccdf1"]/arf:content/TestResult/rule-result[result!="pass" and result!="notselected" and result != "notapplicable"])' /workspace/ssg-results-arf.xml 2> /dev/null)
    echo "XCCDF fails: $XCCDF"
    TOTAL=$((OVAL+XCCDF))
    echo "Total fails: $TOTAL"
    if [ $TOTAL -eq 0 ]; then
        exit 0
    fi
    exit 10
else
    echo "Running manual evaluations"
    shift 2
    # We enable command echo for all oscap commands for transparency/reproducibility
    set -x
    oscap-chroot /mnt "$@"
    set +x
fi