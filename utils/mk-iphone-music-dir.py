#!/usr/bin/env python
import argparse
import os
import re
import sys
import subprocess
import multiprocessing


def debug(message):
    print(f':: {message}', file=sys.stderr)


def find_coverimages(absolute_filepaths):
    """find cover images among the provided file paths
    and return a dictonary mapping directory names to the containing
    cover image"""
    dir2img = {}
    imgfile_re = re.compile(r'.*\.(png|jpg|jpeg|gif)', re.IGNORECASE)
    preferred_name_re = re.compile(r'(cover|album|folder)\.(png|jpg|jpeg|gif)')
    # traverse in reverse order, s.t. earlier entries overwrite latter entries
    for fp in reversed(absolute_filepaths):
        if imgfile_re.match(os.path.basename(fp)):
            dir2img[os.path.dirname(fp)] = fp
    for fp in reversed(absolute_filepaths):
        if preferred_name_re.match(os.path.basename(fp)):
            dir2img[os.path.dirname(fp)] = fp
    return dir2img


class InputFile:
    directory2coverimage = {}  # map absolute directory paths to cover images
    missing_coverimages = set()
    def __init__(self, args, rel_filepath):
        self.args = args
        self.rel_filepath = rel_filepath
        self.abs_filepath = os.path.join(args.SOURCEDIR, rel_filepath)
        self.coverpath = InputFile.directory2coverimage.get(os.path.dirname(self.abs_filepath), None)
        self.rel_basename = os.path.splitext(rel_filepath)[0]
        self.filetype = os.path.splitext(rel_filepath)[1].lower()
        if self.filetype[0:1] == '.':
            self.filetype = self.filetype[1:]
        if self.coverpath is None:
            InputFile.missing_coverimages.add(os.path.dirname(self.abs_filepath))
        self.rel_targetpath = self.rel_basename + '.mp3'
        remove_characters = r'*?\|,;:+=<>[]"' + "\'"
        # self.abs_targetpath = self.abs_targetpath.translate(str.maketrans(remove_characters, len(remove_characters) * '_'))
        self.abs_targetpath = os.path.join(args.TARGETDIR, self.rel_targetpath)

    def convert(self):
        # Main command:
        # ffmpeg -i "$i" -i coverimg.jpg -map_metadata 0 -map 0 -map 1 "targetfile"
        if self.coverpath is None and self.filetype == 'mp3':
            convert_cmd = [
                    "cp", self.abs_filepath, self.abs_targetpath
                    ]
        else:
            convert_cmd = [
                    "ffmpeg",
                    "-hide_banner",
                    "-loglevel", "error",
                    "-i", self.abs_filepath,
            ]
            if self.coverpath is not None:
                convert_cmd += [ "-i", self.coverpath ]
            if self.filetype == 'mp3':
                convert_cmd += [ '-c:a', 'copy' ]
                convert_cmd += [ '-write_id3v1', 'true' ]
            else:
                # https://trac.ffmpeg.org/wiki/Encode/MP3
                # -q:a 1 ---> bitrate 190 - 250
                convert_cmd += [ '-q:a', '1' ]
                convert_cmd += [ '-id3v2_version', '3' ]
            if self.coverpath is not None:
                convert_cmd += [
                    '-map_metadata', '0:s:a:0' if self.filetype == 'ogg' else '0',
                    '-map', '0',
                    '-map', '1',
                ]
            #convert_cmd += [ '-vn' ]
            convert_cmd += [ self.abs_targetpath ]
        if os.path.exists(self.abs_targetpath):
            # debug(f'Skipping existing {self.abs_targetpath}')
            return
        os.makedirs(os.path.dirname(self.abs_targetpath), exist_ok=True)
        print(f'{" ".join(convert_cmd)}')
        subprocess.run(convert_cmd)


def convert_file(sourcefile, coverimg, targetfile):
     # Main command:
     # ffmpeg -i "$i" -i coverimg.jpg -map_metadata 0 -map 0 -map 1 "targetfile"
     pass


def find_files(directory):
    for root, dirnames, filenames in os.walk(directory):
        for fn in filenames:
            yield os.path.join(root, fn)

def convert_file(f):
    f.convert()
    return None

def main():
    """convert a music library to plain mp3 files with
    embedded cover art such that one can copy them to iphone via itunes"""
    parser = argparse.ArgumentParser()
    parser.add_argument('--path-filter', default=None, type=re.compile, help="only consider files whose path contains the given regular expression")
    parser.add_argument('--list-missing-covers', action='store_true', default=False, help="only list missing cover images and then quit")
    parser.add_argument('SOURCEDIR', help="the music library")
    parser.add_argument('TARGETDIR', help="where to write mp3 files to")

    args = parser.parse_args()

    silently_skip_ext = set(['jpg', 'png', 'jpeg', 'gif', 'sh', 'py', 'bmp', 'mid', 'midi',
                             'exe', 'dll', 'inx', 'prx', 'for', 'swp',
                             'tpl', 'm3u',
                             'wav', 'avi', 'mpg',
                             'mood', 'txt', 'lyrics',
                             'log', 'md5', 'sfv', 'nfo', 'nzb', 'ffp', 'css',
                             'pdf', 'rtf',
                             'cue',
                             ])
    supported_extensions = set(['mp3', 'flac', 'ogg'])

    # collect input files:
    absolute_filepaths = sorted(find_files(args.SOURCEDIR))
    InputFile.directory2coverimage = find_coverimages(absolute_filepaths)

    files = []
    for i in absolute_filepaths:
        if i.endswith('~'):
            continue
        _, ext = os.path.splitext(i)
        if ext[0:1] == '.':
            ext = ext[1:]  # remove leading '.'
        if ext.lower() in silently_skip_ext:
            continue
        if args.path_filter and not args.path_filter.search(i):
            continue
        obj = InputFile(args, os.path.relpath(i, args.SOURCEDIR))
        if obj.filetype not in supported_extensions:
            debug(f'Unknown type {obj.filetype} of {obj.rel_filepath}')
        files.append(obj)

    if args.list_missing_covers:
        for i in sorted(InputFile.missing_coverimages):
            debug(f'No cover image in {i}')
        return

    # for f in files:
    #     f.convert()

    with multiprocessing.Pool() as pool_obj:
        pool_obj.map(convert_file, files)


main()
