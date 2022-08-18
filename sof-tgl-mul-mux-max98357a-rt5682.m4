#
# Topology for Tigerlake with CODEC amp + rt5682 codec + DMIC + 4 HDMI
#

# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')
include(`ssp.m4')
include(`hda.m4')

# Include TLV library
include(`common/tlv.m4')

# Include Token library
include(`sof/tokens.m4')

# Include Tigerlake DSP configuration
include(`platform/intel/'PLATFORM`.m4')

# Include machine driver definitions
include(`platform/intel/intel-boards.m4')

include(`muxdemux.m4')

DEBUG_START

define(matrix1, `ROUTE_MATRIX(1,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,0)')')

dnl name, num_streams, route_matrix list
MUXDEMUX_CONFIG(demux_priv_1, 1, LIST_NONEWLINE(`', `matrix1'))


# PCM0 --> volume --> demux --> SSP$AMP_SSP (Speaker - CODEC)


# playback DAI is SSP1 using 2 periods
# # Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
 DAI_ADD(sof/pipe-mixer-volume-dai-playback.m4,
	         0, SSP, 1, SSP1-Codec,
                 NOT_USED_IGNORED, 2, s32le,
                 1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER, 2, 48000)



dnl PIPELINE_PCM_ADD(pipeline,
dnl     pipe id, pcm, max channels, format,
dnl     frames, deadline, priority, core)

PIPELINE_PCM_ADD(sof/pipe-volume-demux-playback.m4,
	1, 0, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER,
	PIPELINE_PLAYBACK_SCHED_COMP_0)


PIPELINE_PCM_ADD(sof/pipe-host-volume-playback.m4,
	2, 1, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER,
	PIPELINE_PLAYBACK_SCHED_COMP_0)


PIPELINE_PCM_ADD(sof/pipe-host-volume-playback.m4,
	3, 2, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER,
	PIPELINE_PLAYBACK_SCHED_COMP_0)


PIPELINE_PCM_ADD(sof/pipe-host-volume-playback.m4,
	4, 3, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER,
	PIPELINE_PLAYBACK_SCHED_COMP_0)


PIPELINE_PCM_ADD(sof/pipe-host-volume-playback.m4,
	5, 4, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER,
	PIPELINE_PLAYBACK_SCHED_COMP_0)

PIPELINE_PCM_ADD(sof/pipe-host-volume-playback.m4,
	6, 5, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER,
	PIPELINE_PLAYBACK_SCHED_COMP_0)



SectionGraph."mixer-host" {
	index "0"
	lines [
		# connect mixer dai pipelines to PCM pipelines
		dapm(PIPELINE_MIXER_0, PIPELINE_SOURCE_1)
		dapm(PIPELINE_MIXER_0, PIPELINE_SOURCE_2)
		dapm(PIPELINE_MIXER_0, PIPELINE_SOURCE_3)
		dapm(PIPELINE_MIXER_0, PIPELINE_SOURCE_4)
		dapm(PIPELINE_MIXER_0, PIPELINE_SOURCE_5)
		dapm(PIPELINE_MIXER_0, PIPELINE_SOURCE_6)
	]
}


# PCM Low Latency, id 0
PCM_PLAYBACK_ADD(MUX_MUL, 0, PIPELINE_PCM_1)
PCM_PLAYBACK_ADD(PCM2, 1, PIPELINE_PCM_2)
PCM_PLAYBACK_ADD(PCM3, 2, PIPELINE_PCM_3)
PCM_PLAYBACK_ADD(PCM4, 3, PIPELINE_PCM_4)
PCM_PLAYBACK_ADD(PCM5, 4, PIPELINE_PCM_5)
PCM_PLAYBACK_ADD(PCM6, 5, PIPELINE_PCM_6)

#
# BE conf2igurations - overrides config in ACPI if present
#
dnl DAI_CONFIG(type, dai_index, link_id, name, ssp_config/dmic_config)
dnl SSP_CONFIG(format, mclk, bclk, fsync, tdm, ssp_config_data)
dnl SSP_CLOCK(clock, freq, codec_master, polarity)
dnl SSP_CONFIG_DATA(type, idx, valid bits, mclk_id)
dnl mclk_id is optional
dnl ssp1-maxmspk

# SSP SPK_SSP_INDEX (ID: SPK_BE_ID)
DAI_CONFIG(SSP, 1, 7, SSP1-Codec,
	SSP_CONFIG(DSP_B, SSP_CLOCK(mclk, 19200000, codec_mclk_in),
		SSP_CLOCK(bclk, 6144000, codec_slave),
		SSP_CLOCK(fsync, 48000, codec_slave),
		SSP_TDM(4, 32, 3, 15),
		SSP_CONFIG_DATA(SSP, 1, 32)))
DEBUG_END
