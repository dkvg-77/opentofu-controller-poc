# tofu-controller-poc — Terraform source

Hello-world infra for the OpenTofu Controller PoC. Creates a single GCS bucket with
labels (labels exist so we can demo drift detection). State is remote in GCS.

This repo is the **Git source** that a Flux `GitRepository` pulls and tofu-controller
reconciles. Edits here flow to the cluster on the next reconcile.
