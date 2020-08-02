package test

import (
  "testing"
  "fmt"
  "github.com/rs/xid"
  "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsHelloWorldExample(t *testing.T) {
  t.Parallel()

  // Create randomized name parameter for each test so we avoid clashes
  RandomizedName := fmt.Sprintf("test-case-%s", xid.New().String()[0:8])

  // Use wildcard ACM Certificate
  ACMCertificateARN := "arn:aws:acm:us-east-1:921809084865:certificate/2387a941-4dde-4ba3-8709-f456ed223d26"

  terraformOptions := &terraform.Options{
    TerraformDir: "../examples/full",
    Vars: map[string]interface{} {
      "name": RandomizedName,
      "root_domain": fmt.Sprintf("%s.viljami.io", RandomizedName),
      "subdomains": []string{},
      "acm_certificate_arn": ACMCertificateARN,
      "allowlist_ipv4": []string{ "10.0.0.0/8" },
      "allowlist_ipv6": []string{ "2001:0db8:0000:0000:0000:0000:0000:0000/64" },
    },
  }

  // At the end of the test, run `terraform destroy` to clean up any resources that were created.
  defer terraform.Destroy(t, terraformOptions)

  // Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
  terraform.InitAndApply(t, terraformOptions)
}
