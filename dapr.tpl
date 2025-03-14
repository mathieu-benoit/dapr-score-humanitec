- op: set
  path: services.placement.image
  value: daprio/dapr
- op: set
  path: services.placement.command
  value: ["./placement", "-port", "50006"]
- op: set
  path: services.placement.ports
  value:
  - target: 50006
    published: "50006"