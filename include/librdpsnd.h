
#ifndef _LIBRDPSND_H
#define _LIBRDPSND_H

#include <stdint.h>

#define LIBRDPSND_ERROR_NONE                    0
#define LIBRDPSND_ERROR_MEMORY                  -1
#define LIBRDPSND_ERROR_SEND_DATA               -2
#define LIBRDPSND_ERROR_PROCESS_DATA            -3
#define LIBRDPSND_ERROR_SEND_CONFIRM            -4
#define LIBRDPSND_ERROR_FORMATS                 -5

struct format_t
{
    uint16_t wFormatTag;
    uint16_t nChannels;
    uint32_t nSamplesPerSec;
    uint32_t nAvgBytesPerSec;
    uint16_t nBlockAlign;
    uint16_t wBitsPerSample;
    uint16_t cbSize;
    void* data;
};

struct rdpsnd_t
{
    int (*log_msg)(struct rdpsnd_t* rdpsnd, const char* msg);
    int (*send_data)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                     void* data, uint32_t bytes);
    int (*close)(struct rdpsnd_t* rdpsnd, uint16_t channel_id);
    int (*wave)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                uint16_t time_stamp, uint16_t format_no, uint8_t block_no,
                void* data, uint32_t bytes);
    int (*volume)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                  uint32_t volume);
    int (*pitch)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                 uint32_t pitch);
    int (*formats)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                   uint16_t version, uint8_t block_no,
                   uint16_t num_formats, struct format_t* formats);
    void* user;
};

int rdpsnd_init(void);
int rdpsnd_deinit(void);
int rdpsnd_create(struct rdpsnd_t** rdpsnd);
int rdpsnd_delete(struct rdpsnd_t* rdpsnd);
int rdpsnd_process_data(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                        void* data, uint32_t bytes);

int rdpsnd_send_confirm(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                        uint16_t timestamp, uint8_t block_no);

#endif
