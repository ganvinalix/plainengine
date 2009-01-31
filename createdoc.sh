rm ./docs/* 2> /dev/null > /dev/null
cat ./src/*.h ./src/*.p > ./_plainEngine.h
autogsdoc ./_plainEngine.h -MakeFrames YES -DocumentationDirectory ./docs/ -Project plainEngine 2> /dev/null > /dev/null
rm ./_plainEngine.h

