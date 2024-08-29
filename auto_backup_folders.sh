#!/bin/sh

FOLDERS="dotfiles org"
LOGFILE="$HOME/autobackup.log"

for folder in $FOLDERS
do
              echo "8 $HOME/$folder"
              cd "$HOME/$folder" #|| echo "Failed to enter into $HOME/$folder" >> "$LOGFILE" && exit 1
              if [ "$(git status --porcelain| wc -l)"  -gt "0"  ]
              then
                    git add . 2>> "$LOGFILE" &&
                    git commit -m "auto-backup $(date '+%Y-%m-%d %H:%I:%S')" 2>> "$LOGFILE" &&
                    git push origin master 2>> "$LOGFILE"
                    if [ "$?" -gt "0" ]
                    then
                      echo "auto-backup $(date '+%Y-%m-%d %H:%I:%S') FAILED" >> "$LOGFILE"
                    fi
              fi
done
echo "auto-backup $(date '+%Y-%m-%d %H:%I:%S') success" >> "$LOGFILE"
exit 0
