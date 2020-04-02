#!/usr/bin/env bash


# Create a dummy secret as a workaround to not having real secrets
oc create secret generic cincinnati-credentials --from-literal=""


# Create a new project
#oc new-project cincinnati


# Apply oc template
oc new-app -f dist/openshift/cincinnati.yaml \
  -p RUST_BACKTRACE="1" \
  -p IMAGE_TAG="90efacd" \
  -p GB_MEMORY_REQUEST=256Mi \
  -p GB_CPU_REQUEST=400m \
  -p PE_MEMORY_REQUEST=256Mi \
  -p PE_CPU_REQUEST=400m \
  -p GB_PAUSE_SECS=120 \
  -p GB_PLUGIN_SETTINGS="$(cat <<-EOF
      [[plugin_settings]]
      name = "release-scrape-dockerv2"
      repository = "openshift-release-dev/ocp-release"
      fetch_concurrency = 16

      [[plugin_settings]]
      name = "github-secondary-metadata-scrape"
      github_org = "openshift"
      github_repo = "cincinnati-graph-data"
      reference_branch = "master"
      output_directory = "/tmp/cincinnati-graph-data"

      [[plugin_settings]]
      name = "openshift-secondary-metadata-parse"
      data_directory = "/tmp/cincinnati-graph-data"

      [[plugin_settings]]
      name = "edge-add-remove"
EOF
)" \
  -p ENVIRONMENT_SECRETS="{}" \
  ;

