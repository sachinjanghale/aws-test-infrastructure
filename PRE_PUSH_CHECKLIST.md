# Pre-Push Checklist

Complete this checklist before pushing to GitHub to ensure everything is ready.

## ✅ Code Quality

- [ ] Run `terraform fmt -recursive` (format all files)
- [ ] Run `terraform validate` (validate configuration)
- [ ] No syntax errors in any files
- [ ] All modules have proper documentation
- [ ] Code comments are clear and helpful

## ✅ Security

- [ ] No `terraform.tfvars` file in repository
- [ ] No `.pem` or `.key` files in repository
- [ ] No AWS credentials in code
- [ ] No hardcoded secrets or passwords
- [ ] `.gitignore` includes all sensitive files
- [ ] Review all files for sensitive data

## ✅ Documentation

- [ ] README.md is complete and accurate
- [ ] All links work (no broken links)
- [ ] Code examples are tested
- [ ] Cost estimates are up to date
- [ ] CONTRIBUTING.md is clear
- [ ] LICENSE file is present
- [ ] CHANGELOG.md is updated

## ✅ Configuration

- [ ] `terraform.tfvars.example` is complete
- [ ] All variables have descriptions
- [ ] Default values are sensible
- [ ] Module toggles work correctly
- [ ] Cost limits are documented

## ✅ GitHub Setup

- [ ] Replace `sachinjanghale` with actual username
- [ ] Update repository URLs
- [ ] Issue templates are configured
- [ ] PR template is configured
- [ ] GitHub Actions workflow is valid
- [ ] Branch protection rules documented

## ✅ Testing

- [ ] `terraform init` works
- [ ] `terraform plan` works
- [ ] `terraform apply` works (if possible)
- [ ] `terraform destroy` works (if possible)
- [ ] All scripts are executable
- [ ] Scripts run without errors

## ✅ Files Present

### Core Files
- [ ] LICENSE
- [ ] README.md
- [ ] CONTRIBUTING.md
- [ ] CODE_OF_CONDUCT.md
- [ ] CHANGELOG.md
- [ ] .gitignore
- [ ] .gitattributes

### Documentation
- [ ] QUICK_START.md
- [ ] GITHUB_SETUP.md
- [ ] PROJECT_SUMMARY.md
- [ ] EDGE_CASES.md
- [ ] BACKEND_SETUP.md
- [ ] TROUBLESHOOTING.md
- [ ] COST_ESTIMATION.md
- [ ] IAM_PERMISSIONS.md

### GitHub Files
- [ ] .github/workflows/terraform-validate.yml
- [ ] .github/ISSUE_TEMPLATE/bug_report.md
- [ ] .github/ISSUE_TEMPLATE/feature_request.md
- [ ] .github/PULL_REQUEST_TEMPLATE.md
- [ ] .github/markdown-link-check-config.json

### Scripts
- [ ] PUSH_TO_GITHUB.sh (executable)
- [ ] scripts/check-costs.sh (executable)
- [ ] scripts/validate-config.sh (executable)

### Terraform Files
- [ ] main.tf
- [ ] variables.tf
- [ ] outputs.tf
- [ ] versions.tf
- [ ] cost_estimation.tf
- [ ] terraform.tfvars.example

## ✅ Content Review

- [ ] No typos in documentation
- [ ] Technical accuracy verified
- [ ] Cost estimates are realistic
- [ ] Examples are working
- [ ] Links are correct
- [ ] Images load (if any)

## ✅ Legal

- [ ] License is appropriate (MIT)
- [ ] Copyright year is correct
- [ ] No proprietary code included
- [ ] No third-party code without attribution
- [ ] Terms are clear

## ✅ Community

- [ ] Code of Conduct is present
- [ ] Contributing guidelines are clear
- [ ] Issue templates are helpful
- [ ] PR template is comprehensive
- [ ] Support channels are documented

## ✅ Branding

- [ ] Repository name is good
- [ ] Description is compelling
- [ ] Topics/tags are relevant
- [ ] Badges are working
- [ ] README is attractive

## ✅ Final Checks

- [ ] Project builds successfully
- [ ] All tests pass
- [ ] Documentation is complete
- [ ] No TODO comments in code
- [ ] Version number is correct (1.0.0)
- [ ] Ready for public release

## 🚀 Ready to Push?

If all items are checked, you're ready to push to GitHub!

### Quick Commands

```bash
# Format code
terraform fmt -recursive

# Validate
terraform validate

# Check for sensitive files
ls -la | grep -E "\.tfvars$|\.pem$|\.key$"

# Check git status
git status

# Run the push script
./PUSH_TO_GITHUB.sh
```

## 📝 Notes

Use this space to note any issues or items that need attention:

```
[Your notes here]
```

---

**Once everything is checked, run `./PUSH_TO_GITHUB.sh` to push to GitHub! 🎉**
