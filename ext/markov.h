#ifndef MARKOV_H
#define MARKOV_H

struct markov
{
	int i;
};

struct markov *create_mar();
void free_mar(struct markov *m);

void mar_add_text(struct markov *m, const char *s);
char *mar_gen_sent(struct markov *m);

#endif

