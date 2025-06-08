
#ifndef _LIBRDPSND_H
#define _LIBRDPSND_H

#include <stdint.h>

#define LIBRDPSND_ERROR_NONE                    0
#define LIBRDPSND_ERROR_MEMORY                  -1

struct rdpsnd_t
{
    int (*log_msg)(struct rdpsnd_t* rdpsnd, const char* msg);
    int (*send_data)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                     void* data, uint32_t bytes);
};

int rdpsnd_init(void);
int rdpsnd_deinit(void);

#endif
