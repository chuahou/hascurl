// SPDX-License-Identifier: MIT
// Copyright (c) 2021 Chua Hou

#include <curl/curl.h>
#include <string.h>
#include <stdlib.h>

#include "hascurl.h"

#define RETURN_ERR -1

struct write_out {
	char *data;  // Pointer to start of data.
	size_t size; // Bytes copied so far.
};

// Write callback function that copies curled data from in to out. Returns 0
// if anything fails (e.g. memory allocation), upon which the CURLcode will be
// set away from CURLE_OK.
size_t write_callback(
		char *in, size_t size, size_t nmemb, struct write_out *out)
{
	// Size of new data.
	size_t total_size = size * nmemb;

	// Resize memory to fit new data.
	out->data = realloc(out->data, out->size + total_size + 1);
	if (out->data) {
		memcpy(&out->data[out->size], in, total_size);
		out->size += total_size;
		out->data[out->size] = '\0';
		return total_size; // Tell curl we've copied everything.
	}

	// Failed to allocate, tell curl we've not copied anything.
	else return 0;
}

char *get(char *url)
{
	CURL *curl = curl_easy_init();
	if (curl) {
		struct write_out wout = { .data = NULL, .size = 0 };
		curl_easy_setopt(curl, CURLOPT_URL, url);
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &wout);
		CURLcode result = curl_easy_perform(curl);
		curl_easy_cleanup(curl);
		return (result == CURLE_OK) ? wout.data : NULL;
	} else {
		return NULL;
	}
}
