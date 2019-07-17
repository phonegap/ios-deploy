## 1. Increment a version

```
npm --no-git-tag-version version [major | minor | patch]
# get the package.json version in a variable
export PKG_VER=`node -e "console.log(require('./package.json').version)"`
git commit -m "Incremented version to $PKG_VER" package.json src/src/ios-deploy/version.h
```

## 2. Tag a version

```
git tag $PKG_VER
```

## 3. Push version and tag

```
git push origin master
git push origin $PKG_VER
```