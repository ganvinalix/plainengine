rm ./docs/* 2> /dev/null > /dev/null
autogsdoc ./src/*.h -MakeFrames YES -DocumentationDirectory ./docs/ -Project plainEngine 2> /dev/null > /dev/null
