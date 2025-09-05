# SonarQube CI/CD Integration Setup

This project is configured to run SonarQube analysis on every commit and pull request to detect code smells in new code only.

## 🔧 Setup Requirements

### 1. GitHub Secrets Configuration

Add these secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

```
SONAR_TOKEN=<your-sonarqube-token>
SONAR_HOST_URL=<your-sonarqube-server-url>
```

### 2. SonarQube Server Setup

#### Option A: SonarQube Cloud (Recommended for production)
1. Go to [SonarQube Cloud](https://sonarcloud.io/)
2. Create account and import your GitHub repository
3. Generate token: `My Account > Security > Generate Tokens`
4. Set `SONAR_HOST_URL=https://sonarcloud.io`

#### Option B: Self-hosted SonarQube
1. Keep your local SonarQube running on `http://localhost:9000`
2. For GitHub Actions, use a publicly accessible SonarQube instance
3. Generate token: `Administration > Security > Users > Tokens`

### 3. Project Configuration in SonarQube

1. **Create Project:**
   - Project key: `notetakingmvcuikit`
   - Project name: `Note Taking MVC UIKit`

2. **Configure New Code Period:**
   - Go to `Project Settings > New Code`
   - Select "Reference branch" → `main`

3. **Set Quality Gate:**
   - Use "Sonar way" or create custom gate
   - Focus on "Overall Code" and "New Code" conditions

## 🚀 How It Works

### On Every Push to main/develop:
- Full project analysis
- Updates overall project metrics
- Historical trend tracking

### On Every Pull Request:
- **New Code Analysis Only** - focuses on changed files
- Automatic PR decoration with:
  - 🐛 New bugs introduced
  - 🔒 New security vulnerabilities
  - 💨 Code smells in changed code
  - 📊 Coverage on new code
  - 🔄 Duplications in new code

### Quality Gate:
- Blocks PR merge if quality gate fails
- Configurable thresholds for new code
- Automatic status checks in GitHub

## 📊 Viewing Results

### In GitHub:
- Check status in PR checks
- View automatic comments on PRs
- See quality gate status

### In SonarQube:
- Dashboard: Overview of all metrics
- Pull Requests tab: PR-specific analysis
- Issues tab: Filter by "New Code" period
- Activity tab: Historical analysis

## 🎯 New Code Focus Features

The configuration specifically targets new code changes:

```properties
# Focus on changes since main branch
sonar.newCode.referenceBranch=main

# Quality gate waits for analysis
sonar.qualitygate.wait=true

# GitHub PR decoration
sonar.pullrequest.github.endpoint=https://api.github.com/
```

## 🛠️ Local Testing

Test the configuration locally:

```bash
# Ensure SonarQube is running
curl http://localhost:9000/api/system/status

# Run analysis with token
sonar-scanner -Dsonar.token=YOUR_TOKEN

# Test PR analysis simulation
sonar-scanner \
  -Dsonar.token=YOUR_TOKEN \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature-branch \
  -Dsonar.pullrequest.base=main
```

## 🔍 What Gets Analyzed

### Included:
- All `.swift` files in `notetakingmvcuikit/`
- Unit tests in `notetakingmvcuikitTests/`
- UI tests in `notetakingmvcuikitUITests/`

### Excluded:
- Xcode assets and storyboards
- Core Data model files
- Property list files
- Localization files

## 📈 Code Smell Categories

SonarQube will detect:

1. **Maintainability Issues:**
   - Complex methods
   - Large classes
   - Code duplication

2. **Reliability Issues:**
   - Potential bugs
   - Exception handling

3. **Security Vulnerabilities:**
   - Hardcoded credentials
   - Weak cryptography

4. **Coverage Issues:**
   - Uncovered new code
   - Missing tests

## 🏃‍♂️ Quick Start

1. Add GitHub secrets (SONAR_TOKEN, SONAR_HOST_URL)
2. Create project in SonarQube with key `notetakingmvcuikit`
3. Push code or create PR
4. Check GitHub Actions tab for analysis results
5. View detailed results in SonarQube dashboard

The workflows will automatically trigger and provide code smell analysis focused on new code changes only!