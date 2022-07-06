#!/bin/bash
#
# 统计 @leif160519/ 子目录的细节
#

awk -f- <( \

    cd /mnt/mfs/@leif160519 && \
    find prometheus                 -mindepth 1 -maxdepth 1 -type d -exec mfsdirinfo -i -d -f -c -l -s -r {} \; && \
    find jenkins                    -mindepth 1 -maxdepth 1 -type d -exec mfsdirinfo -i -d -f -c -l -s -r {} \; && \
    find backuppc                   -mindepth 1 -maxdepth 1 -type d -exec mfsdirinfo -i -d -f -c -l -s -r {} \; && \
    cd /mnt && \
    find mfs                        -mindepth 1 -maxdepth 1 -type d -exec mfsdirinfo -i -d -f -c -l -s -r {} \;

) <<'EOF'

function mfsdirinfo(line) {
    split(line, info)

    inodes  =info[1]
    dirs    =info[2]
    files   =info[3]
    chunks  =info[4]
    len     =info[5]
    size    =info[6]
    real    =info[7]
    path    =info[8]

    printf "moosefs_inodes_count{path=\"%s\"} %d\n", path, inodes
    printf "moosefs_dirs_count{path=\"%s\"} %d\n",   path, dirs
    printf "moosefs_files_count{path=\"%s\"} %d\n",  path, files
    printf "moosefs_chunks_count{path=\"%s\"} %d\n", path, chunks
    printf "moosefs_length_bytes{path=\"%s\"} %d\n", path, len
    printf "moosefs_size_bytes{path=\"%s\"} %d\n",   path, size
    printf "moosefs_real_bytes{path=\"%s\"} %d\n",   path, real
}

{
    mfsdirinfo($0)
}

EOF
