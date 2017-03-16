// ffmpegTest.cpp : Defines the entry point for the console application.
//Program to extract the motion vectors for a given input video directory

#include "stdafx.h"
#include "stdio.h"
#include "conio.h"
#include "windows.h"
#include "dirent.h"
#include <fstream>
#include <iostream>
#include <string>
using namespace std;


extern "C"
{
#include <libavutil/motion_vector.h>
#include <libavformat/avformat.h>
# pragma comment (lib, "avformat.lib")
}
static AVFormatContext *fmt_ctx = NULL;
static AVCodecContext *video_dec_ctx = NULL;
static AVStream *video_stream = NULL;
static const char *src_filename = NULL;

static int video_stream_idx = -1;
static AVFrame *frame = NULL;
static AVPacket pkt;
static int video_frame_count = 0;

static string video_file_directory;
static int r;
//static const char* output_file=NULL;
const char * cf = NULL;
FILE *fp;
int video_no = 0;

string output_file;
static int decode_packet(int *got_frame, int cached)
{
	int decoded = pkt.size;

	*got_frame = 0;

	if (pkt.stream_index == video_stream_idx) {
		int ret = avcodec_decode_video2(video_dec_ctx, frame, got_frame, &pkt);
		if (ret < 0) {
			//TODO : Fix the below line
			//fprintf(stderr, "Error decoding video frame (%s)\n", av_err2str(ret));
			return ret;
		}

		if (*got_frame) {
			int i;
			AVFrameSideData *sd;
			
			// divide the matrix into r cells logically
			int column_divider = floor(video_dec_ctx->width / r);
			int row_divider = floor(video_dec_ctx->height / r);
			
			video_frame_count++;
			sd = av_frame_get_side_data(frame, AV_FRAME_DATA_MOTION_VECTORS);
			if (sd) {
				const AVMotionVector *mvs = (const AVMotionVector *)sd->data;
				for (i = 0; i < sd->size / sizeof(*mvs); i++) {
					const AVMotionVector *mv = &mvs[i];
					
					float x_coord_val = (float) mv->dst_x / column_divider;
					float y_coord_val = (float) mv->dst_y / row_divider;
					int x_coord = ceil(x_coord_val);
					int y_coord = ceil(y_coord_val);

					int cell_no = (x_coord - 1)*(floor(video_dec_ctx->width / column_divider)) + y_coord;


					printf("[%d %d %d %d %d %d %d %d %d] \n", video_frame_count, cell_no, mv->source, mv->w, mv->h, mv->src_x, mv->src_y, mv->dst_x, mv->dst_y);

					
					fprintf(fp, "%d %d %d %d %d %d %d %d %d %d \n", video_no, video_frame_count, cell_no, mv->source, mv->w, mv->h, mv->src_x, mv->src_y, mv->dst_x, mv->dst_y );
					
				}
				
				
			}
		}
	}

	return decoded;
}

static int open_codec_context(int *stream_idx,
	AVFormatContext *fmt_ctx, enum AVMediaType type)
{
	int ret;
	AVStream *st;
	AVCodecContext *dec_ctx = NULL;
	AVCodec *dec = NULL;
	AVDictionary *opts = NULL;

	ret = av_find_best_stream(fmt_ctx, type, -1, -1, NULL, 0);
	if (ret < 0) {
		fprintf(stderr, "Could not find %s stream in input file '%s'\n",
			av_get_media_type_string(type), src_filename);
		return ret;
	}
	else {
		*stream_idx = ret;
		st = fmt_ctx->streams[*stream_idx];

		/* find decoder for the stream */
		dec_ctx = st->codec;
		dec = avcodec_find_decoder(dec_ctx->codec_id);
		if (!dec) {
			fprintf(stderr, "Failed to find %s codec\n",
				av_get_media_type_string(type));
			return AVERROR(EINVAL);
		}

		/* Init the video decoder */
		av_dict_set(&opts, "flags2", "+export_mvs", 0);
		if ((ret = avcodec_open2(dec_ctx, dec, &opts)) < 0) {
			fprintf(stderr, "Failed to open %s codec\n",
				av_get_media_type_string(type));
			return ret;
		}
	}

	return 0;
}

int main(int argc, char **argv)
{
	int ret = 0, got_frame;

	// get the input values
	cout << "Enter the input video directory\n";
	cin >> video_file_directory;

	cout << "Enter the value of r\n";
	cin >> r;

	cout << "Enter the output file name\n";
	cin >> output_file;

	//Use the dirent library to read files in a directory
	//http://stackoverflow.com/questions/612097/how-can-i-get-the-list-of-files-in-a-directory-using-c-or-c
	
	DIR *dir; 
	struct dirent *ent;
	const char * video_directory = video_file_directory.c_str();
	cf = output_file.c_str();
	fp = fopen(cf, "a+");

	char file[100];
	strcpy(file, video_directory);
	if ((dir = opendir(video_directory)) != NULL) {
		
		while ((ent = readdir(dir)) != NULL) {
			
			size_t len = strlen(ent->d_name);

			//check for .mp4 files in the directory
			// http://stackoverflow.com/questions/12976733/how-can-i-get-only-txt-files-from-directory-in-c
			if (len > 4 && strcmp(ent->d_name + len - 4, ".mp4") == 0)
			{
				video_no = video_no + 1;
				video_frame_count = 0;
				src_filename = "";
				strcpy(file, video_directory);
				src_filename = strcat(file, ent->d_name);
				
			}
			else
			{
				printf("Else %s ", ent->d_name);
				continue;
			}

			av_register_all();

			if (avformat_open_input(&fmt_ctx, src_filename, NULL, NULL) < 0) {
				fprintf(stderr, "Could not open source file %s\n", src_filename);
				exit(1);
			}

			if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
				fprintf(stderr, "Could not find stream information\n");
				exit(1);
			}

			if (open_codec_context(&video_stream_idx, fmt_ctx, AVMEDIA_TYPE_VIDEO) >= 0) {
				video_stream = fmt_ctx->streams[video_stream_idx];
				video_dec_ctx = video_stream->codec;
			}

			av_dump_format(fmt_ctx, 0, src_filename, 0);

			if (!video_stream) {
				fprintf(stderr, "Could not find video stream in the input, aborting\n");
				ret = 1;
				goto end;
			}

			frame = av_frame_alloc();
			if (!frame) {
				fprintf(stderr, "Could not allocate frame\n");
				ret = AVERROR(ENOMEM);
				goto end;
			}

			printf("framenum,source,blockw,blockh,srcx,srcy,dstx,dsty,flags\n");


			/* initialize packet, set data to NULL, let the demuxer fill it */
			av_init_packet(&pkt);
			pkt.data = NULL;
			pkt.size = 0;

			/* read frames from the file */
			while (av_read_frame(fmt_ctx, &pkt) >= 0) {
				AVPacket orig_pkt = pkt;
				do {
					ret = decode_packet(&got_frame, 0);
					if (ret < 0)
						break;
					pkt.data += ret;
					pkt.size -= ret;
				} while (pkt.size > 0);
				av_packet_unref(&orig_pkt);
			}

			/* flush cached frames */
			pkt.data = NULL;
			pkt.size = 0;
			do {
				decode_packet(&got_frame, 1);
			} while (got_frame);


			avcodec_close(video_dec_ctx);
			avformat_close_input(&fmt_ctx);
			av_frame_free(&frame);
			

		}

		closedir(dir);
	}
	else {
		/* could not open directory */
		perror("");
		//return EXIT_FAILURE;
	}


end:
	fclose(fp);
	return ret < 0;

}

