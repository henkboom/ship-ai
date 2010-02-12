NAME=simulator

# always descend
.PHONY: $(NAME)

# bootstrap
linux:
	make $(NAME) PLATFORM=linux

macosx:
	make $(NAME) PLATFORM=macosx

mingw:
	make $(NAME) PLATFORM=mingw

# actual building

ai_loader.o: ai_loader.c
	gcc -O2 -Wall -c $^

$(NAME):
	make -C dokidoki-support $(PLATFORM) NAME="../$(NAME)" EXTRA_CFLAGS='-DEXTRA_LOADERS=\"../extra_loaders.h\"' EXTRA_OBJECTS="../ai_loader.o"

clean:
	rm -f particles.o
	make -C dokidoki-support clean NAME="../$(NAME)"

