#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "markov.h"

#define SENTENCE_TERMS ".\n"

enum PARSE_STATES
{
	FINISHED,
	FIND_BEG,
	FIND_END,
	ADD_SENTENCE,
};

static int chrpbrk(char c, const char *accept);
static void mar_add_sentence(struct markov *m,
	const char *beg, const char *end);



/*********************
 * Private functions *
 *********************/

/* chrpbrk
 *
 * Checks to see if C is any of the chars in ACCEPT. Analagous to strpbrk(3)
 * except with a character instead of a string.
 */
static int chrpbrk(char c, const char *accept)
{
	while (*accept)
		if (*accept++ == c)
			return 1;
	return 0;
}

/* mar_add_sentence
 *
 * Analyzes a sentence and teaches the markov chain about which words come
 * after one another.
 */
static void mar_add_sentence(struct markov *m,
	const char *beg, const char *end)
{
	printf("ADDING ");
	while (*beg != *end)
		putchar(*beg++);
	putchar('\n');
}



/********************
 * Public functions *
 ********************/

struct markov *create_mar()
{
	struct markov *m = (struct markov*)malloc(sizeof(struct markov));
	return m;
}

void free_mar(struct markov *m)
{
	free(m);
}

/* mar_add_text
 *
 * Tries to break TEXT into "sentences". Calls mar_add_sentence on each.
 */
void mar_add_text(struct markov *m, const char *text)
{
	const char *beg, *end;
	int state;

	if (text == NULL || text[0] == '\0')
		return;

	beg = text;
	state = FIND_BEG;

	while (state != FINISHED) {
		switch (state) {
		case FIND_BEG:
			while (chrpbrk(*beg, SENTENCE_TERMS))
				beg++;
			state = FIND_END;
			break;
		case FIND_END:
			end = strpbrk(beg, SENTENCE_TERMS);
			state = end ? ADD_SENTENCE : FINISHED;
			break;
		case ADD_SENTENCE:
			mar_add_sentence(m, beg, end);
			beg = end+1;
			state = FIND_BEG;
			break;
		}
	}
}

/* mar_gen_sent
 *
 * Stub.
 */
char *mar_gen_sent(struct markov *m)
{
	return strdup("<generate sentence stub>");
}

