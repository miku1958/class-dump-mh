//  This file is a part of class-dump v2, a utility for examining the
//  Objective-C segment of Mach-O files.
//  Copyright (C) 1997-1998, 2000-2001, 2004  Steve Nygard

#include <stdio.h>
#include <libc.h>

#import "rcsid.h"
#import <Foundation/Foundation.h>
#import "NSString-Extensions.h"

#import "CDClassDump.h"

RCS_ID("$Header: /Volumes/Data/tmp/Tools/class-dump/main.m,v 1.4 2004/02/11 01:08:18 nygard Exp $");

void print_usage(void)
{
    fprintf(stderr,
            "class-dump %s\n"
            "Usage: class-dump [options] mach-o-file\n"
            "\n"
            "  where options are:\n"
            "        -a        show instance variable offsets\n"
            "        -A        show implementation addresses\n"
            "        -C regex  only display classes matching regular expression\n"
            "        -H        generate header files in current directory, or directory specified with -o\n"
            "        -I        sort classes, categories, and protocols by inheritance (overrides -s)\n"
            "        -o dir    output directory used for -H\n"
            "        -r        recursively expand frameworks and fixed VM shared libraries\n"
            "        -s        sort classes and categories by name\n"
            "        -S        sort methods by name\n"
            ,
            [CLASS_DUMP_VERSION UTF8String]
       );
}

extern int optind;
extern char *optarg;

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CDClassDump *classDump;

    int ch;
    BOOL errorFlag = NO;

    if (argc == 1) {
        print_usage();
        exit(2);
    }

    classDump = [[[CDClassDump alloc] init] autorelease];

    while ( (ch = getopt(argc, argv, "aAC:HIo:rRsS")) != EOF) {
        switch (ch) {
          case 'a':
              [classDump setShouldShowIvarOffsets:YES];
              break;

          case 'A':
              [classDump setShouldShowMethodAddresses:YES];
              break;

          case 'C':
          {
              NSString *errorMessage;

              if ([classDump setRegex:optarg errorMessage:&errorMessage] == NO) {
                  NSLog(@"Error with regex: '%@'\n\n", errorMessage);
                  errorFlag = YES;
              }
              // Last one wins now.
          }
              break;

          case 'H':
              [classDump setShouldGenerateSeparateHeaders:YES];
              break;

          case 'I':
              [classDump setShouldSortClassesByInheritance:YES];
              break;

          case 'o':
              [classDump setOutputPath:[NSString stringWithCString:optarg]];
              break;

          case 'r':
              [classDump setShouldProcessRecursively:YES];
              break;

          case 's':
              [classDump setShouldSortClasses:YES];
              break;

          case 'S':
              [classDump setShouldSortMethods:YES];
              break;

          case '?':
          default:
              errorFlag = YES;
              break;
        }
    }

    if (errorFlag == YES) {
        print_usage();
        exit(2);
    }

    if (optind < argc) {
        NSString *path;

        path = [NSString stringWithFileSystemRepresentation:argv[optind]];
        [classDump processFilename:path];
        [classDump generateOutput];
    }

    [pool release];

    return 0;
}
