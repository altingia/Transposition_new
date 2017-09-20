echo "test run"
python RunRelocaTEi_bam_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam > log 2> log2 &
python RunRelocaTEi_bam_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam_simulation > log 2> log2 &
echo "test with existingRun: subdata extracted"
python RunRelocaTEi_bam_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam --existingRun ./v2 > log 2> log2&
echo "ref as chr3 not whole genome, whole genome give less confident. but we still need to use whole genome"
python RunRelocaTEi_bam_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam_simulation --genome /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/MSU7.Chr3.fa
echo "test mping, ping, pong: when using similar element like ping and mping, some read will map to both, will get confused some place, less confident at breakpoint"
python RunRelocaTEi_bam_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam_simulation --repeat /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/TE/mping_all.fa > log 2> log2 &
echo "test Insert Size"
python RunInsertSize.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam &
echo "test temp"
python RunTEMP_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam_simulation > log 2> log2 &
python RunTEMP_Pop_qsub.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam_simulation > log 2> log2 &

echo "Run RelocaTEi on 275 RILs"
python RunInsertSize.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam --project RIL275 > log 2> log2 &
python RunRelocaTEi_bam_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam --project RIL275_RelocaTEi > log 2> log2 &
python RunCheckResults.py --input RIL275_RelocaTEi --tools RelocaTEi > RIL275_RelocaTEi.lowcpmping.list
python RunRelocaTEi_sumtable.py --input RIL275_RelocaTEi
python RunRelocaTEi_sumtable_clean.py --input RIL275_RelocaTEi
python RunRelocaTEi_CombinedGFF.py --input RIL275_RelocaTEi


echo "Run TEMP on 275 RILs"
python RunTEMP_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam --project RIL275_TEMP > log 2> log2 & 
python RunTEMP_Pop_qsub.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/input/bam --project RIL275_TEMP > log 2> log2 &
python RunCheckResults.py --input RIL275_TEMP --tools TEMP > RIL275_TEMP.lowcpmping.list
python RunTEMP_sumtable.py --input RIL275_TEMP


echo "Run RelocaTE on 275 RILs"
cut -f2,3 EG4.mping.all_reference.txt > Nipponbare.mPing.txt
python RunRelocaTE_Pop.py --input /rhome/cjinfeng/BigData/00.RD/RILs/QTL_pipe/input/fastq/RILs_ALL_fastq --project RIL275_RelocaTE
python RunCheckResults.py --input RIL275_RelocaTE --tools RelocaTE > RIL275_RelocaTE.lowcpmping.list

python RunRelocaTE_CombinedGFF.py --input RIL275_RelocaTE

echo "add unique mping"
python MergeTable.py --table1 Compare_fig/RIL275_RelocaTEi.summary.table --table2 RIL275_RelocaTE.sofia.unique.table2 > Compare_fig/RIL275_RelocaTEi_unique.summary.table

echo "update to 230 core, blackout problem RILs"
python BlackOut_230core.py --input Bam.Core.blacklist


echo "Run RelocaTE2_mPing on corrected RIL sequence: RIL5/6, RIL145/152, RIL243 still problem"
python ReNameSRA_RelocaTEi_mPing.py --input RILs_ALL_fastq_correct_merged --repeat /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/mping.fa > log 2>&1
python ReNameSRA_RelocaTEi_mPing.py --input RILs_ALL_fastq_correct_merged --repeat /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/ping.fa > log 2>&1
python ReNameSRA_RelocaTEi_mPing.py --input RILs_ALL_fastq_correct_merged --repeat /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/pong.fa > log 2>&1
python ReNameSRA_RelocaTEi_OtherTE.py --input RILs_ALL_fastq_correct_merged --repeat /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/Rice.TE.short.unique.fa > log 2>&1
python ReNameSRA_RelocaTEi_OtherTE.py --input RILs_ALL_fastq_correct_merged_test --repeat /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/Rice.TE.short.unique.fa > log 2>&1
python ReNameSRA_sum_unfinished.py --input RILs_ALL_fastq_correct_merged_RelocaTEi
python ReNameSRA_clean_finished.py --input RILs_ALL_bam_correct_merged_RelocaTEi
echo "Rerun mping/ping/pong because bwa.0.7.9 does not allow pair-end to have difference read id"
python ReNameSRA_RelocaTEi_ReRunOnResults_all.py --input RILs_ALL_fastq_correct_merged_RelocaTEi
#rerun ping and pong using repeatmasker file generated by mping/ping/pong, manual edit ref ping and double pong coordinate
python ReNameSRA_RelocaTEi_ReRunOnResults_absence.py --input RILs_ALL_fastq_correct_merged_RelocaTEi
python ReNameSRA_sum_Ping.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_Ping --list rice_line_IRRI_2466.download.list
python ReNameSRA_sum_Pong.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_Pong --list rice_line_IRRI_2466.download.list
python ReNameSRA_sum_mPing.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_mPing --list rice_line_IRRI_2466.download.list
python ReNameSRA_sumtable_clean.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_mPing > log 2>&1 &
echo "summary for analysis"
#characterize hom/het/som
python ReNameSRA_failed_characterize.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_mPing
#summarize for analysis
python ReNameSRA_CombinedGFF.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_mPing
python ReNameSRA_sumtable_clean.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_mPing
python ReNameSRA_sum_mPing.py --input RILs_ALL_fastq_correct_merged_RelocaTEi_mPing

echo "Run RelocaTE2_mPing on 275 RILs using bam"
python RunInsertSize.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/bin/RILs_ALL_bam_correct_merged --project RILs_ALL_bam_correct_merged > log 2> log2 &
python ReNameSRA_RelocaTEi_mPing_bam.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/bin/RILs_ALL_bam_correct_merged_test --project RILs_ALL_bam_correct_merged_test > log 2> log2 &
python ReNameSRA_RelocaTEi_mPing_bam.py --input /rhome/cjinfeng/BigData/00.RD/RILs/Transpostion/bin/RILs_ALL_bam_correct_merged --project RILs_ALL_bam_correct_merged > log 2> log2 &
echo "summarize for analysis"
python ReNameSRA_CombinedGFF.py --input RILs_ALL_bam_correct_merged_RelocaTEi_mPing
python ReNameSRA_sumtable_clean.py --input RILs_ALL_bam_correct_merged_RelocaTEi_mPing


echo "Run mPing using RelocaTE2, which is more reliable than RelocaTE2_mPing for confident call. Have bugs when deal with two closely related mPing: Chr10:2854243-2854245"
python ReNameSRA_RelocaTEi_mPing_RelocaTE2.py --input RILs_ALL_fastq_correct_merged_duplicate --repeat /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/mping.fa > log 2>&1 &
#reruned failed call
python ReNameSRA_failed_rerun.py --input RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi
python ReNameSRA_rerun.py --input RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi
#characterize hom/het/som
python ReNameSRA_failed_characterize.py --input RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi
#summary
python ReNameSRA_sumtable_clean.py --input RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi
#compare with old verions
paste test.summary_clean.table RILs_ALL_bam_correct_merged_RelocaTEi_mPing.summary_clean.table RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi.summary_clean.table | cut -f1,7-13,14,20-26,27,33-39 > test.summary_clean.table.comparision.txt
#summarize for analysis
python ReNameSRA_CombinedGFF.py --input RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi
python ReNameSRA_sumtable_clean.py --input RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi
python ReNameSRA_sum_mPing.py --input RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi

echo "Update RIL131 because it is duplicate with RIL188, 20170919"
python ReNameSRA_RelocaTEi_mPing_RelocaTE2.py --input RILs_ALL_fastq_correct_merged_test --repeat /rhome/cjinfeng/BigData/00.RD/RelocaTE_i/Simulation/Reference/mping.fa > log 2>&1 &
python ReNameSRA_failed_characterize.py --input RILs_ALL_fastq_correct_merged_test_RelocaTEi > log 2>&1 &
python ReNameSRA_sumtable_clean.py --input RILs_ALL_fastq_correct_merged_test_RelocaTEi
cd RILs_ALL_fastq_correct_merged_duplicate_RelocaTEi
mv ../RILs_ALL_fastq_correct_merged_test_RelocaTEi/RIL131_RelocaTEi ./

