#include <stdio.h>
#include <stdlib.h>

#include "ruby.h"

#include "markov.h"

VALUE rb_mar_new(VALUE class);
static void rb_mar_free(void *m);
VALUE rb_mar_init(VALUE self);
VALUE rb_mar_add_text(VALUE self, VALUE text);
VALUE rb_mar_gen_sent(VALUE self);

VALUE rb_mar_new(VALUE class)
{
	struct markov *m;
	VALUE obj;

	m = (struct markov*)malloc(sizeof(struct markov));
	obj = Data_Wrap_Struct(class, 0, rb_mar_free, m);
	rb_obj_call_init(obj, 0, NULL);
	return obj;
}

static void rb_mar_free(void *mar)
{
	free(mar);
}

VALUE rb_mar_init(VALUE self)
{
	return self;
}

VALUE rb_mar_add_text(VALUE self, VALUE text)
{
	return Qnil;
}

VALUE rb_mar_gen_sent(VALUE self)
{
	return rb_str_new2("<generate sentence stub>");
}

VALUE mar_hello(VALUE self)
{
	return rb_str_new2("Hello from C!");
}

VALUE mar_get_type_string(VALUE self, VALUE obj)
{
	switch (TYPE(obj)) {
	case T_FIXNUM:
		return rb_str_new2("C says: number");
	case T_STRING:
		return rb_str_new2("C says: string");
	default:
		return rb_str_new2("C says: unknown type");
	}
}

VALUE mar_read_test_file(VALUE self)
{
	FILE *f;
	char buf[512];

	f = fopen("test.txt", "r");
	if (!f)
		return rb_str_new2("C says: File not found");
	memset(buf, 0, sizeof(buf));
	fgets(buf, sizeof(buf), f);
	fclose(f);
	return rb_str_new2(buf);
}

VALUE mar_set(VALUE self, VALUE obj)
{
	struct markov *m;
	Data_Get_Struct(self, struct markov, m);

	m->i = NUM2INT(obj);
	return Qnil;
}

VALUE mar_get(VALUE self)
{
	struct markov *m;
	Data_Get_Struct(self, struct markov, m);

	return INT2NUM(m->i);
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

