# Agent Upgrades

## Pipeline Order

1. `infra-ci` will automatically run basic tests. (Packer CI in ADO)
2. Run `packer-build-image` to build the image for the agents.
3. Run `infra-cd` to deliver the image to ACR and set it as the one to use. (Packer Agent CD in ADO)
4. Run `purge-agent-images` to delete older images in ACR.

## Info

- All pipelines use the image `pool: ubuntu-latest`

## Node.js Configuration for Self-Hosted Agents

### Overview
Our self-hosted Azure DevOps agents have Node.js pre-installed via NVM with **symlinks in `/usr/local/bin/`** for global access. This eliminates the need for `UseNode@1` tasks in pipelines.

### Available Node.js Versions
- **Node.js 20.x** (LTS Iron)
- **Node.js 22.x** (LTS Jod) - **Default**
- **Node.js 24.x** (LTS Krypton)

### How It Works
The `tools.sh` script creates symlinks during agent image build:
```bash
/usr/local/bin/node -> /usr/local/nvm/versions/node/v22.x.x/bin/node
/usr/local/bin/npm  -> /usr/local/nvm/versions/node/v22.x.x/bin/npm
/usr/local/bin/npx  -> /usr/local/nvm/versions/node/v22.x.x/bin/npx
```

### Switching Default Node.js Version
Use the provided utility script on agents:
```bash
# Switch to Node.js 20
./update-node-symlinks.sh 20

# Switch to Node.js 24  
./update-node-symlinks.sh 24

# Switch back to Node.js 22 (default)
./update-node-symlinks.sh 22
```

### Pipeline Updates Required

#### ❌ Remove These Tasks
```yaml
# Remove UseNode@1 tasks - no longer needed
- task: UseNode@1
  displayName: "Set Node Version"
  inputs:
    version: '20.x'

# Remove NodeTool@0 tasks - no longer needed  
- task: NodeTool@0
  displayName: 'Use Node 22'
  inputs:
    versionSpec: '22'
```

#### ✅ Node.js Available Directly
```yaml
# Node.js commands work directly - no setup required
- script: |
    node --version    # Works immediately
    npm install      # Works immediately  
    npx cypress run  # Works immediately
  displayName: 'Run Node.js Commands'
```

#### 🔄 If Different Version Needed
For pipelines requiring a specific Node.js version, use NVM setup:
```yaml
- script: |
    export NVM_DIR="/usr/local/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use 20  # or 22, 24
    node --version
  displayName: 'Setup Specific Node Version'
```

### Benefits
- ⚡ **Faster pipelines** - No Node.js download/install steps
- 🧹 **Cleaner YAML** - Remove boilerplate setup code
- 💾 **Reduced bandwidth** - No repeated Node.js downloads
- 🎯 **Consistent environment** - Same Node.js across all agents
