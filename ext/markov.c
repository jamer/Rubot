#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "markov.h"

struct markov *create_mar()
{
	struct markov *m = (struct markov*)malloc(sizeof(struct markov));
	return m;
}

void free_mar(struct markov *m)
{
	free(m);
}


void mar_add_text(struct markov *m, const char *s)
{
}

char *mar_gen_sent(struct markov *m)
{
	return strdup("<generate sentence stub>");
}

