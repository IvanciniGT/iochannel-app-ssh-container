
parse_git_branch() { 
   BRANCH=$(git branch --show-current 2> /dev/null)
   if [[ -n "$BRANCH" ]]; then
	BRANCH="[$BRANCH] "
   fi
   echo "$BRANCH"
}

export PS1="\[\033[32m\]\$(parse_git_branch)\[\033[00m\]\[\033[33;1m\]\w\[\033[m\] $ "

if [ -f ~/.git-completion.bash ]; then
   source ~/.git-completion.bash
fi

[[ -n "$USER_NAME" ]] && git config --global user.name "$USER_NAME"
[[ -n "$USER_EMAIL" ]] && git config --global user.email "$USER_EMAIL"
git config --global color.ui true

cd /home/alumno/environment