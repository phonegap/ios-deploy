#ifndef _errors_h
#define _errors_h

typedef struct {
	unsigned int error;
	const char*  id;
} errorcode_to_id_t;

typedef struct {
	const char* id;
	const char* message;
} error_id_to_message_t;

const char* get_error_message(unsigned int error);

#endif
