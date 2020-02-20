# gitflow-for-node

https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

## Install

```sh
$ ./install.sh
```

## Command lines

### Start Feature

```bash
$ BRANCH_NAME='feature/name'
$ git checkout develop
$ git push -u origin develop
$ git checkout -b $BRANCH_NAME
$ unset BRANCH_NAME
```

### Finish Feature

```bash
$ BRANCH_NAME='feature/name'
$ git checkout develop
$ git pull origin develop
$ git merge --no-ff --no-edit $BRANCH_NAME
$ git branch -D $BRANCH_NAME
$ git push -u origin develop
$ unset BRANCH_NAME
```

### Start Release

```bash
$ BRANCH_NAME='release/name'
$ git checkout develop
$ git pull origin develop
$ git checkout -b $BRANCH_NAME
$ git tag $(git describe)
$ unset BRANCH_NAME
```

### Finishi Release

```bash
$ BRANCH_NAME='release/name'
$ git checkout master
$ git pull origin master
$ git merge --no-ff --no-edit $BRANCH_NAME
$ npm version [major|minor] -m "Upgrade to %s"
$ CURRENT_VERSION=$(git describe)
$ git checkout develop
$ git pull origin develop
$ git merge --no-ff --no-edit $CURRENT_VERSION
$ git branch -D $BRANCH_NAME
$ git push -u origin master
$ git push -u origin develop
$ unset BRANCH_NAME
$ unset CURRENT_VERSION
```

### Start Hotfix

```bash
$ BRANCH_NAME='hotfix/name'
$ git checkout master
$ git pull origin master
$ git checkout -b $BRANCH_NAME
$ unset BRANCH_NAME
```

### Finishi Hotfix

```bash
$ BRANCH_NAME='hotfix/name'
$ git checkout master
$ git pull origin master
$ git merge --no-ff --no-edit $BRANCH_NAME
$ npm version patch -m "Upgrade to %s"
$ CURRENT_VERSION=$(git describe)
$ git checkout develop
$ git pull origin develop
$ git merge --no-ff --no-edit $CURRENT_VERSION
$ git branch -D $BRANCH_NAME
$ git push -u origin master
$ git push -u origin develop
$ unset BRANCH_NAME
$ unset CURRENT_VERSION
```