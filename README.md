# Platelets_TB
Transcriptomic analysis of platelet-enriched RNA under Mtb infection.

---

## How to Contribute

### 1. Fork the Repository
Fork the repository to create your own copy under your GitHub account.

### 2. Clone Your Forked Repository
Clone the forked repository to your local machine.

```bash
# Replace <your-username> with your GitHub username
git clone https://github.com/<your-username>/Platelets_TB.git
```

### 3. Set the Original Repository as an Upstream Remote
This ensures you can keep your fork updated with changes from the original repository.

```bash
cd Platelets_TB
# Add the original repository as an upstream remote
git remote add upstream https://github.com/BigMindLab/Platelets_TB.git
```

### 4. Pull Changes from the Original Repository
Before starting work, ensure your fork is up-to-date with the latest changes from the main branch.

```bash
# Fetch changes from the original repository
git fetch upstream

# Merge changes into your local main branch
git checkout main
git merge upstream/main
```

### 5. Create a New Branch
Create a new branch for your changes. Use a descriptive name for the branch.

```bash
# Replace <branch-name> with a descriptive name for your branch
git checkout -b <branch-name>
```

### 6. Make, commit and push your changes
Push your local branch to your forked repository on GitHub.

```bash
# After making your changes
git add .
git commit -m "Brief description of your changes"

# Replace <branch-name> with your branch name
git push origin <branch-name>
```

### 7. Create a Pull Request
Go to the original repository on GitHub (`BigMindLab/Platelets_TB`).
1. Click on the **Pull Requests** tab.
2. Click **New Pull Request**.
3. Select your branch as the source and the original repository's `main` branch as the target.
4. Add a description of your changes and submit the pull request.

---

### Notes
- If your pull request addresses a specific issue, reference the issue number in your description (e.g., "RIN threshold #42").

Thank you for contributing!

