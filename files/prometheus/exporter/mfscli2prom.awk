#!/usr/bin/awk -f
#
# usage: 
#
#   % /usr/bin/mfscli -ns"#" -SIM -SMU -SIG -SCS -SIC -SSC -SQU | ./mfscli2prom.awk
#
# moosefs >= v3.0.105
#

BEGIN {
    FS="[#:|]"
}

function SCS() {
    k=gensub(/\s/, "_", "g", $1);
    printf "moosefs_%s_load{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} %s\n", k,$3,$4,$5,$6,$7,$8;

    if ($9 ~ /maintenance_off/) {
        printf "moosefs_%s_maintenance{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} 0\n", k,$3,$4,$5,$6,$7;
    } else {
        printf "moosefs_%s_maintenance{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} 0\n", k,$3,$4,$5,$6,$7;
    }

    printf "moosefs_%s_regular_hdd_space_chunks{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} %s\n", k,$3,$4,$5,$6,$7,$10;
    printf "moosefs_%s_regular_hdd_space_used{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} %s\n", k,$3,$4,$5,$6,$7,$11;
    printf "moosefs_%s_regular_hdd_space_total{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} %s\n", k,$3,$4,$5,$6,$7,$12;

    printf "moosefs_%s_removal_hdd_space_chunks{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} %s\n", k,$3,$4,$5,$6,$7,$14;
    printf "moosefs_%s_removal_hdd_space_used{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} %s\n", k,$3,$4,$5,$6,$7,$15;
    printf "moosefs_%s_removal_hdd_space_total{ip=\"%s\",port=\"%s\",id=\"%s\",labels=\"%s\",version=\"%s\"} %s\n", k,$3,$4,$5,$6,$7,$16;

}

function is_number(x) { return x+0 == x }
function SIG() {
    if (!is_number($NF)) next

    v=$NF;
    $(NF--);

    k=$0;
    k=gensub(/\s+/, "_", "g", k);
    k=gensub(/[()]/, "", "g", k);
    k=tolower(k)

    print "moosefs_"k,v
}

function SIM() {
    k=gensub(/\s/, "_", "g", $1);

    printf "moosefs_%s_metadata_version{ip=\"%s\", version=\"%s\"} %d\n", k,$3,$4,gensub(/[ ]/, "", "g", $7)
    printf "moosefs_%s_ram_used{ip=\"%s\", version=\"%s\"} %d\n", k,$3,$4,$9

    printf "moosefs_%s_cpu_used_all{ip=\"%s\", version=\"%s\"} %f\n", k,$3,$4,gensub(/(.*)%.*/, "\\1", "g", $11)
    printf "moosefs_%s_cpu_used_sys{ip=\"%s\", version=\"%s\"} %f\n", k,$3,$4,gensub(/(.*)%.*/, "\\1", "g", $12)
    printf "moosefs_%s_cpu_used_user{ip=\"%s\", version=\"%s\"} %f\n", k,$3,$4,gensub(/(.*)%.*/, "\\1", "g", $13)
    printf "moosefs_%s_last_meta_save{ip=\"%s\", version=\"%s\", cksum=\"%s\"} %d\n", k,$3,$4,$NF,$14
    printf "moosefs_%s_last_save_duration{ip=\"%s\", version=\"%s\", cksum=\"%s\"} %f\n", k,$3,$4,$NF,$15

    if ($16 ~ /[Ss]aved in background/){
        printf "moosefs_%s_last_saved_in_background{ip=\"%s\", version=\"%s\", cksum=\"%s\"} 1\n", k,$3,$4,$NF
    } else {
        printf "moosefs_%s_last_saved_in_background{ip=\"%s\", version=\"%s\", cksum=\"%s\"} 0\n", k,$3,$4,$NF
    }
}

function SMU() {
#    k=gensub(/\s/, "_", "g", $1);
#
#    printf "moosefs_%s_%s_used %s\n", k, gensub(/\s/, "_", "g", $3), $4
#    printf "moosefs_%s_%s_allocated %s\n", k, gensub(/\s/, "_", "g", $3), $5
}

function SIC() {
    k=gensub(/\s/, "_", "g", $1) "_" gensub(/\s/, "_", "g", $3);

    printf "moosefs_%s %s\n", k, $5
}

function SSC() {
    k=gensub(/\s/, "_", "g", $1);
    C=gensub(/\s/, "", "g", $17);
    K=gensub(/\s/, "", "g", $20);
    A=gensub(/\s/, "", "g", $23);
    printf "moosefs_%s_create{id=\"%s\",name=\"%s\",mode=\"%s\",can=\"%s\",labels=\"%s\"} %s\n", k,$3,$4,$6,$15,C,$16
    printf "moosefs_%s_keep{id=\"%s\",name=\"%s\",mode=\"%s\",can=\"%s\",labels=\"%s\"} %s\n", k,$3,$4,$6,$18,K,$19
    printf "moosefs_%s_archive{id=\"%s\",name=\"%s\",mode=\"%s\",can=\"%s\",labels=\"%s\"} %s\n", k,$3,$4,$6,$21,A,$22

    printf "moosefs_%s_files_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$7
    printf "moosefs_%s_dirs_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$8
    printf "moosefs_%s_standard_under_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$9
    printf "moosefs_%s_standard_exact_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$10
    printf "moosefs_%s_standard_over_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$11
    printf "moosefs_%s_archived_under_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$12
    printf "moosefs_%s_archived_exact_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$13
    printf "moosefs_%s_archived_over_total{id=\"%s\",name=\"%s\"} %d\n", k,$3,$4,$14
}

function SQU() {
    k=gensub(/\s/, "_", "g", $1);  # keyword
    P=gensub(/\s/, "",  "g", $3);  # path
    SI=gensub(/\s/, "", "g", $7);  # soft inodes
    SL=gensub(/\s/, "", "g", $8);  # soft length
    SS=gensub(/\s/, "", "g", $9);  # soft size
    SR=gensub(/\s/, "", "g", $10);  # soft real size
    HI=gensub(/\s/, "", "g", $11); # hard inodes
    HL=gensub(/\s/, "", "g", $12); # hard length
    HS=gensub(/\s/, "", "g", $13); # hard size
    HR=gensub(/\s/, "", "g", $14); # hard real size
    CI=gensub(/\s/, "", "g", $15); # current inodes
    CL=gensub(/\s/, "", "g", $16); # current length
    CS=gensub(/\s/, "", "g", $17); # current size
    CR=gensub(/\s/, "", "g", $18); # current real size

    printf "moosefs_%s_soft_inodes{path=\"%s\"} %d\n",    k,P,SI
    printf "moosefs_%s_soft_length{path=\"%s\"} %d\n",    k,P,SL
    printf "moosefs_%s_soft_size{path=\"%s\"} %d\n",      k,P,SS
    printf "moosefs_%s_soft_real{path=\"%s\"} %d\n",      k,P,SR

    printf "moosefs_%s_hard_inodes{path=\"%s\"} %d\n",    k,P,HI
    printf "moosefs_%s_hard_length{path=\"%s\"} %d\n",    k,P,HL
    printf "moosefs_%s_hard_size{path=\"%s\"} %d\n",      k,P,HS
    printf "moosefs_%s_hard_real{path=\"%s\"} %d\n",      k,P,HR

    printf "moosefs_%s_current_inodes{path=\"%s\"} %d\n",     k,P,CI
    printf "moosefs_%s_current_length{path=\"%s\"} %d\n",     k,P,CL
    printf "moosefs_%s_current_size{path=\"%s\"} %d\n",       k,P,CS
    printf "moosefs_%s_current_real{path=\"%s\"} %d\n",       k,P,CR
}

{
    if ($0 ~ /^\s*$/) next

    if ($0 ~ /^active quotas:/)
        SQU()

    if ($0 ~ /^metadata servers:/)
        SIM()

    if ($0 ~ /^memory usage detailed info:/)
        SMU()

    if ($0 ~ /^chunk servers:/)
        SCS()

    if ($0 ~ /^master info:/)
        SIG()

    if ($0 ~ /chunkclass /)
        SIC()

    if ($0 ~ /storage classes:/)
        SSC()
}
