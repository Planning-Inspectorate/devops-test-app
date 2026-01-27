# Easy Git Cheatsheet

Copy & paste into OneNote. Windows-friendly commands.

## Setup (once)
```
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf true
```

## Start a new repo
```
mkdir my-project && cd my-project
git init
echo "# My Project" > README.md
git add .
git commit -m "Initial commit"
```

## Clone an existing repo
```
git clone https://github.com/owner/repo.git
cd repo
```

## Daily workflow
```
git status
git add .
git commit -m "Clear, concise message"
git push
```

## Branching
```
git switch -c feature/my-change      # create + switch
git push -u origin feature/my-change # first push sets upstream
git switch main                      # go back to main
```

## Sync with remote
```
git fetch
git pull            # update current branch
git pull --rebase   # optional: keep history linear
```

## Fix common mistakes
```
git restore --staged path/to/file    # unstage
git restore path/to/file             # discard local change
git commit --amend                   # edit last commit
git revert <commit>                  # make a new undo commit
git reset --soft HEAD~1              # undo commit, keep changes staged
git reset --hard HEAD~1              # WARNING: discard changes
```

## Stash (save WIP)
```
git stash push -m "WIP"
git stash list
git stash pop
```

## History quick views
```
git log --oneline --graph --decorate --all
git show HEAD
```

## Tags (releases)
```
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

## Rescue lost work
```
git reflog
git checkout -b rescue <reflog-commit>
```
