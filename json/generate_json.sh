ls ../../../data/clean*.txt | perl6 -ne '.IO ==> (-> $in { say qqx[tsv2json $in > {$in.basename.split(".")[0] ~ ".json"}] })()'
