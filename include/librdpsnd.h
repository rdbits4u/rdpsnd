
#ifndef _LIBRDPSND_H
#define _LIBRDPSND_H

#include <stdint.h>

#define LIBRDPSND_ERROR_NONE                    0
#define LIBRDPSND_ERROR_MEMORY                  -1
#define LIBRDPSND_ERROR_SEND_DATA               -2
#define LIBRDPSND_ERROR_PROCESS_DATA            -3
#define LIBRDPSND_ERROR_SEND_WAVECONFIRM        -4
#define LIBRDPSND_ERROR_PROCESS_FORMATS         -5
#define LIBRDPSND_ERROR_SEND_FORMATS            -6
#define LIBRDPSND_ERROR_PROCESS_TRAINING        -7
#define LIBRDPSND_ERROR_SEND_TRAINING           -8
#define LIBRDPSND_ERROR_PROCESS_WAVE            -9

// struct rdpsnd_t::process_formats:flags

// The client is capable of consuming audio data. This flag MUST be set for audio data
// to be transferred.
#define TSSNDCAPS_ALIVE     0x00000001
// The client is capable of applying a volume change to all the audio data that is
// received.
#define TSSNDCAPS_VOLUME    0x00000002
// The client is capable of applying a pitch change to all the audio data that is
// received.
#define TSSNDCAPS_PITCH     0x00000004

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
    int (*process_close)(struct rdpsnd_t* rdpsnd, uint16_t channel_id);
    int (*process_wave)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                        uint16_t time_stamp, uint16_t format_no,
                        uint8_t block_no, void* data, uint32_t bytes);
    int (*process_volume)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                          uint32_t volume);
    int (*process_pitch)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                         uint32_t pitch);
    int (*process_waveconfirm)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                               uint16_t timestamp, uint8_t block_no);
    int (*process_training)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                            uint16_t time_stamp, uint16_t pack_size,
                            void* data, uint32_t bytes);
    int (*process_formats)(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                           uint32_t flags, uint32_t volume,
                           uint32_t pitch, uint16_t dgram_port,
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
int rdpsnd_send_close(struct rdpsnd_t* rdpsnd, uint16_t channel_id);
int rdpsnd_send_wave(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                     uint16_t time_stamp, uint16_t format_no,
                     uint8_t block_no, void* data, uint32_t bytes);
int rdpsnd_send_volume(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                       uint32_t volume);
int rdpsnd_send_pitch(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                      uint32_t pitch);

int rdpsnd_send_waveconfirm(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                            uint16_t timestamp, uint8_t block_no);
int rdpsnd_send_training(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                         uint16_t time_stamp, uint16_t pack_size,
                         void* data, uint32_t bytes);
int rdpsnd_send_formats(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
                        uint32_t flags, uint32_t volume,
                        uint32_t pitch, uint16_t dgram_port,
                        uint16_t version, uint8_t block_no,
                        uint16_t num_formats, struct format_t* formats);

#endif
