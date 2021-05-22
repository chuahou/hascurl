#ifndef __HASCURL_H_INCLUDED__
#define __HASCURL_H_INCLUDED__

/*
 * Performs a GET request to the given url and returns pointer to curled data.
 * Returns NULL if error encountered.
 */
char *get(char *url);

/*
 * Performs a POST request to the given url with the given post fields string
 * and returns pointer to curled data. Returns NULL if error encountered.
 */
char *post(char *url, char *fields);

#endif
