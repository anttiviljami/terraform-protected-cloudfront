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
	RandomizedName := fmt.Sprintf("test-case-%x", xid.New().String()[0:8])

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/full",
		Vars: map[string]interface{} {
				"name": RandomizedName,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created.
	defer terraform.Destroy(t, terraformOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)
}