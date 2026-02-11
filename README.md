# Go Template Repository

This template repository contains a small build system for Go projects.
The code block below initializes the project.
The only manual step is setting up the Git remotes.

```bash
export APP_NAME=
export GO_VERSION=1.26.0
bash -ceu '
if [ -z "${APP_NAME:-}" ]; then printf "APP_NAME must be set\n" >&2; exit 1; fi
git clone https://github.com/egor-georgiev/go_template_repo "$APP_NAME"
cd "$APP_NAME"
sed -i.bak -e "s/%APP_NAME%/$APP_NAME/g" -e "s/%GO_VERSION%/$GO_VERSION/g" Makefile
sed -i.bak "s/%GO_VERSION%/$GO_VERSION/g" Dockerfile
rm -f {Makefile,Dockerfile}.bak
printf "# %s\n" "$APP_NAME" > README.md
printf "%s\n%s_dev\n" "$APP_NAME" "$APP_NAME" > .gitignore
for remote in $(git remote); do git remote remove "$remote"; done
make go args="mod init $APP_NAME"
git add .
git commit --amend --no-edit
make run
'
cd "$APP_NAME"
unset APP_NAME GO_VERSION
```
