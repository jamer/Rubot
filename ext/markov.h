#ifndef MARKOV_H
#define MARKOV_H


struct markov
{
	int i;
};


/* create_mar
 *
 * Creates an empty markov chain.
 */
struct markov *create_mar();

/* free_mar
 *
 * Frees the memory used by a markov chain.
 */
void free_mar(struct markov *m);


/* mar_add_text
 *
 * Analyzes the text and teaches the markov chain about which words come after
 * one another.
 */
void mar_add_text(struct markov *m, const char *text);

/* mar_gen_sent
 *
 * Procedurally generate a sentence based on the state of the markov chain.
 */
char *mar_gen_sent(struct markov *m);


#endif

