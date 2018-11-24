#!/bin/bash
COMMAND="$1"

print_help () {
    echo "========================="
    echo "[command]"
    echo "build"
    echo "local"
    echo "deploy"
    echo "========================="
}


if [ "$COMMAND" == "help" ]
then
    print_help
elif [ "$COMMAND" == "local" ]
then
    bundle exec jekyll build
    bundle exec jekyll serve
elif [ "$COMMAND" == "deploy" ]
then
    bundle exec jekyll build && git push
else
    echo "invalid command"
    print_help
fi


