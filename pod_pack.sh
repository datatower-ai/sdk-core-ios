pod package DataTowerAICore.podspec --force --no-mangle --exclude-deps --configuration=Release --spec-sources="" -embedded

version=$(find . -name DataTowerAICore-* -type d)
version=$(echo $version | cut -d "-" -f 2)
cp -a __Modules/* DataTowerAICore-${version}/ios/DataTowerAICore.framework
