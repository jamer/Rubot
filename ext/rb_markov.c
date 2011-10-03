#include <ruby.h>

#include "markov.h"

static VALUE rb_mar_new(VALUE class)
{
	struct markov *m;
	VALUE obj;

	m = create_mar();
	obj = Data_Wrap_Struct(class, 0, free_mar, m);
	rb_obj_call_init(obj, 0, NULL);
	return obj;
}

static VALUE rb_mar_init(VALUE self)
{
	return self;
}

static VALUE rb_mar_add_text(VALUE self, VALUE text)
{
	struct markov *m;
	char *s;

	Data_Get_Struct(self, struct markov, m);
	s = StringValueCStr(text);
	mar_add_text(m, s);
	return Qnil;
}

static VALUE rb_mar_gen_sent(VALUE self)
{
	struct markov *m;
	char *s;

	Data_Get_Struct(self, struct markov, m);
	s = mar_gen_sent(m);
	VALUE string = rb_str_new2(s);
	free(s);
	return string;
}


VALUE rb_cMarkov = Qnil;

void Init_markov()
{
	rb_cMarkov = rb_define_class("MarkovChain", rb_cObject);
	rb_define_singleton_method(rb_cMarkov, "new", rb_mar_new, 0);
	rb_define_method(rb_cMarkov, "initialize", rb_mar_init, 0);
	rb_define_method(rb_cMarkov, "add_text", rb_mar_add_text, 1);
	rb_define_method(rb_cMarkov, "generate_sentence", rb_mar_gen_sent, 0);
}

