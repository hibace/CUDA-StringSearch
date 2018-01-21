#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<iostream>
using namespace std;

// GPU method
__global__ void searchText(char* data, char* keyword, int dataLen,int keyLen)
{
	int found = 0;
	int i = (blockIdx.x * 1024) + threadIdx.x;
				int checkNext = i;
				for(int j = 0;j < keyLen; j++)
                        	{
					if(data[checkNext] == keyword[j])
                        		{
						checkNext++;
						if(j==keyLen - 1)
						{
							found = 1;
							break;
						}
					
                        		}
                        		else
                        		{
						break;
                        		}
				}	
	
	if(found == 1){
		printf("Match found at %d\n",i);	
		
	}
}


int main(int argc, char* argv[])
{
	char* str = (char*)malloc(512 * sizeof(char));
	char* str1 = (char*)malloc(512 * sizeof(char));
	printf("Enter the input file which has to be searched\n");
	scanf ("%s",str);
	printf("Enter the dictionary with the keywords to be searched \n");
	scanf("%s",str1);
	printf("input = %s\ndict = %s\n",str,str1);

	
	char *buf,*tok;
	buf = (char*)malloc(500 *sizeof(char));
	tok = (char*)malloc(500 *sizeof(char));
	FILE *f = fopen(str, "r");
	fseek(f, 0, SEEK_END);
	long fsize = ftell(f);
	fseek(f, 0, SEEK_SET);

	char *text = (char *)malloc((fsize + 1) * sizeof(char));
	printf("reading..\n");
	fread(text, fsize, 1, f);
	printf("done...\n");
	fclose(f);
	int noOfBlocks = strlen(text)/1024;	
	noOfBlocks++;
	printf("text size = %d\nfsize = %d\n",noOfBlocks,fsize);
	

	char* d_text;
	cudaMalloc((void**)&d_text, strlen(text) * sizeof(char));
	cudaMemcpy(d_text, text, strlen(text) * sizeof(char), cudaMemcpyHostToDevice);
	FILE *f1 = fopen(str1,"r");
        while(fgets(buf,512,f1))
	{
	
	char* keys = (char*)malloc(128 * sizeof(char));
        tok = strtok(buf,"\t"); 
        printf("searching for = %s\n",tok);
	strcpy(keys,tok);
        cudaSetDevice(0);

        char* d_keys;
       
        cudaMalloc((void**)&d_keys, strlen(keys) * sizeof(char));
        cudaMemcpy(d_keys, keys, strlen(keys) * sizeof(char), cudaMemcpyHostToDevice);
       
        searchText<<<noOfBlocks, 1024>>>(d_text, d_keys, strlen(text),strlen(keys));

        cudaDeviceSynchronize();

        cudaFree(d_keys);

        free(keys);
	}
	cudaFree(d_text);
	free(text);
	
	
        return 0;
}
