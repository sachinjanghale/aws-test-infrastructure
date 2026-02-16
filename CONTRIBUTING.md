# Contributing to AWS Test Infrastructure

Thank you for your interest in contributing to this project! This document provides guidelines for contributing.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in the [Issues](../../issues) section
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (Terraform version, AWS region, etc.)

### Submitting Changes

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/sachinjanghale/aws-test-infrastructure.git
   cd aws-test-infrastructure
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make your changes**
   - Follow the existing code style
   - Update documentation as needed
   - Test your changes thoroughly

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: Brief description of your changes"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Provide a clear description of your changes

## Development Guidelines

### Code Style

- Use consistent formatting: `terraform fmt -recursive`
- Validate configuration: `terraform validate`
- Follow Terraform best practices
- Add comments for complex logic

### Module Structure

When adding new modules:
```
modules/
└── your_module/
    ├── main.tf       # Resources
    ├── variables.tf  # Input variables
    ├── outputs.tf    # Output values
    └── README.md     # Module documentation
```

### Documentation

- Update README.md for user-facing changes
- Add inline comments for complex configurations
- Update cost estimates when adding resources
- Document any new variables or outputs

### Testing

Before submitting:

1. **Validate syntax**
   ```bash
   terraform validate
   ```

2. **Format code**
   ```bash
   terraform fmt -recursive
   ```

3. **Test deployment** (if possible)
   ```bash
   terraform plan
   terraform apply
   terraform destroy
   ```

4. **Check costs**
   ```bash
   ./scripts/check-costs.sh
   ```

### Commit Message Guidelines

Use clear, descriptive commit messages:

- `Add: New feature or resource`
- `Fix: Bug fix`
- `Update: Modify existing feature`
- `Docs: Documentation changes`
- `Refactor: Code restructuring`
- `Test: Add or update tests`

Examples:
```
Add: RDS instance support with MySQL engine
Fix: S3 bucket lifecycle policy syntax error
Update: Increase Lambda memory to 256MB
Docs: Add troubleshooting guide for VPC errors
```

## Adding New AWS Services

When adding support for new AWS services:

1. **Check cost impact**
   - Prioritize free tier services
   - Document monthly costs
   - Update `cost_estimation.tf`

2. **Create module structure**
   - Follow existing module patterns
   - Add enable/disable flag
   - Include comprehensive outputs

3. **Update documentation**
   - Add to README.md service list
   - Update cost breakdown
   - Add usage examples

4. **Test thoroughly**
   - Verify resource creation
   - Check dependencies
   - Test destruction

## Cost Considerations

This project aims to stay within AWS free tier or minimal cost:

- **Free tier first**: Prioritize services with free tier
- **Minimal resources**: Use smallest instance types
- **Optional expensive services**: Make costly resources optional
- **Document costs**: Always document estimated monthly costs

## Questions?

If you have questions:

- Open an issue with the "question" label
- Check existing issues and discussions
- Review the documentation in the `/docs` folder

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Focus on the project's goals

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🎉
