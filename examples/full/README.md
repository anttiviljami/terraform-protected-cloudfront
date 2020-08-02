# Full Example

This example demonstrates how to use the `terraform-protected-cloudfron` module.

```
terraform init
terraform apply
```

## Generating a Certificate

You can use the aws-cli to generate a certificate for your domains. Please note
that the certificate needs to be validated before use.

```
aws acm request-certificate --domain-name mydomain.com --subject-alternative-names a.example.com b.example.com *.c.example.com
```

## Demo App

The app found under [`./demo-app`](./demo-app) is just a tiny SPA hello world
app hosted on S3 to provide a default origin for this module.
