# Go Template Repository

A minimal template repository for Go projects. The code chunk below initializes the project.

```bash
export APP_NAME=
bash -ceu '
if [ -z "${APP_NAME:-}" ]; then printf "APP_NAME must be set\n" >&2; exit 1; fi
git clone https://github.com/egor-georgiev/go_template_repo "$APP_NAME"
cd "$APP_NAME"
sed -i.bak "s/%APP_NAME%/$APP_NAME/g" Makefile
rm -f Makefile.bak
printf "# %s\n" "$APP_NAME" > README.md
printf "%s\n%s_dev\n" "$APP_NAME" "$APP_NAME" > .gitignore
for remote in $(git remote); do git remote remove "$remote"; done
make go args="mod init $APP_NAME"
git add .
git commit --amend --no-edit
make run
'
cd "$APP_NAME"
unset APP_NAME
```
