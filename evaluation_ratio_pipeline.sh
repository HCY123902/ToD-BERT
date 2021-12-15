gpu=$1
model=$2
bert_dir=$3
output_dir=$4
add1=$5
add2=$6
add3=$7

# ./evaluation_ratio_pipeline.sh 0 bert bert-base-uncased save/BERT --nb_runs=3 

# Intent
for ratio in 0.01 0.1
do
    CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=multi_class_classifier \
    --dataset='["oos_intent"]' \
    --task_name="intent" \
    --earlystop="acc" \
    --output_dir=${output_dir}/Intent/OOS-Ratio/R${ratio} \
    --do_train \
    --task=nlu \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
    --batch_size=16 \
    --usr_token=[USR] --sys_token=[SYS] \
    --epoch=500 --eval_by_step=100 --warmup_steps=100 \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3
done

# DST
for ratio in 0.01 0.05 
do
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=BeliefTracker \
    --model_type=${model} \
    --dataset='["multiwoz"]' \
    --task_name="dst" \
    --earlystop="joint_acc" \
    --output_dir=${output_dir}/DST/MWOZ-Ratio/R${ratio} \
    --do_train \
    --task=dst \
    --example_type=turn \
    --model_name_or_path=${bert_dir} \
    --batch_size=8 --eval_batch_size=8 \
    --usr_token=[USR] --sys_token=[SYS] \
    --eval_by_step=200 \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3
done
for ratio in 0.1 0.25
do
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=BeliefTracker \
    --model_type=${model} \
    --dataset='["multiwoz"]' \
    --task_name="dst" \
    --earlystop="joint_acc" \
    --output_dir=${output_dir}/DST/MWOZ-Ratio/R${ratio} \
    --do_train \
    --task=dst \
    --example_type=turn \
    --model_name_or_path=${bert_dir} \
    --batch_size=8 --eval_batch_size=8 \
    --usr_token=[USR] --sys_token=[SYS] \
    --eval_by_step=500 \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3
done

# DA
for ratio in 0.01 
do
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=multi_label_classifier \
    --do_train --dataset='["multiwoz"]' \
    --task=dm --task_name=sysact --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/DA/MWOZ-Ratio/R${ratio} \
    --batch_size=8 \
    --eval_batch_size=4 \
    --learning_rate=5e-5 \
    --eval_by_step=200 \
    --usr_token=[USR] --sys_token=[SYS] \
    --earlystop=f1_weighted \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=multi_label_classifier \
    --do_train \
    --dataset='["universal_act_dstc2"]' \
    --task=dm --task_name=sysact --example_type=turn \
    --model_type=${model} --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/DA/DSTC2-Ratio/R${ratio} \
    --batch_size=8 \
    --eval_batch_size=4 \
    --learning_rate=5e-5 \
    --eval_by_step=100 \
    --usr_token=[USR] --sys_token=[SYS] \
    --earlystop=f1_weighted \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3

CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=multi_label_classifier \
    --do_train \
    --dataset='["universal_act_sim_joint"]' \
    --task=dm --task_name=sysact --example_type=turn \
    --model_type=${model} --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/DA/SIM_JOINT-Ratio/R${ratio} \
    --batch_size=8 \
    --eval_batch_size=4 \
    --learning_rate=5e-5 \
    --eval_by_step=100 \
    --usr_token=[USR] --sys_token=[SYS] \
    --earlystop=f1_weighted \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3
done

for ratio in 0.1 
do
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=multi_label_classifier \
    --do_train --dataset='["multiwoz"]' \
    --task=dm --task_name=sysact --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/DA/MWOZ-Ratio/R${ratio} \
    --batch_size=8 \
    --eval_batch_size=4 \
    --learning_rate=5e-5 \
    --eval_by_step=500 \
    --usr_token=[USR] --sys_token=[SYS] \
    --earlystop=f1_weighted \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=multi_label_classifier \
    --do_train \
    --dataset='["universal_act_dstc2"]' \
    --task=dm --task_name=sysact --example_type=turn \
    --model_type=${model} --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/DA/DSTC2-Ratio/R${ratio} \
    --batch_size=8 \
    --eval_batch_size=4 \
    --learning_rate=5e-5 \
    --eval_by_step=500 \
    --usr_token=[USR] --sys_token=[SYS] \
    --earlystop=f1_weighted \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3

CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=multi_label_classifier \
    --do_train \
    --dataset='["universal_act_sim_joint"]' \
    --task=dm --task_name=sysact --example_type=turn \
    --model_type=${model} --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/DA/SIM_JOINT-Ratio/R${ratio} \
    --batch_size=8 \
    --eval_batch_size=4 \
    --learning_rate=5e-5 \
    --eval_by_step=500 \
    --usr_token=[USR] --sys_token=[SYS] \
    --earlystop=f1_weighted \
    --train_data_ratio=${ratio} \
    $add1 $add2 $add3
done

    
# RS
for ratio in 0.01 
do
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["irc"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/IRC/ \
    --batch_size=25 --eval_batch_size=100 \
    --max_seq_length=256\
    --fix_rand_seed \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["movie"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/MOVIE/ \
    --batch_size=25 --eval_batch_size=100 \
    --max_seq_length=256 \
    --fix_rand_seed \
    $add1 $add2 $add3

CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --task=nlg \
    --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/RS/MWOZ-Ratio/R${ratio} \
    --batch_size=25 --eval_batch_size=100 \
    --usr_token=[USR] --sys_token=[SYS] \
    --fix_rand_seed \
    --eval_by_step=200 \
    --train_data_ratio=${ratio} \
    --max_seq_length=256 \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["universal_act_dstc2"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/DSTC2-Ratio/R${ratio} \
    --batch_size=25 --eval_batch_size=100 \
    --eval_by_step=100 \
    --train_data_ratio=${ratio} \
    --max_seq_length=256 \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["universal_act_sim_joint"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/SIM_JOINT-Ratio/R${ratio} \
    --batch_size=25 --eval_batch_size=100 \
    --eval_by_step=100 \
    --train_data_ratio=${ratio} \
    --max_seq_length=256 \
    $add1 $add2 $add3
done
for ratio in 0.1 
do
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["irc"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/IRC/ \
    --batch_size=25 --eval_batch_size=100 \
    --max_seq_length=256\
    --fix_rand_seed \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["movie"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/MOVIE/ \
    --batch_size=25 --eval_batch_size=100 \
    --max_seq_length=256 \
    --fix_rand_seed \
    $add1 $add2 $add3

CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --task=nlg \
    --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
    --output_dir=${output_dir}/RS/MWOZ-Ratio/R${ratio} \
    --batch_size=25 --eval_batch_size=100 \
    --usr_token=[USR] --sys_token=[SYS] \
    --fix_rand_seed \
    --eval_by_step=500 \
    --train_data_ratio=${ratio} \
    --max_seq_length=256 \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["universal_act_dstc2"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/DSTC2-Ratio/R${ratio} \
    --batch_size=25 --eval_batch_size=100 \
    --eval_by_step=250 \
    --train_data_ratio=${ratio} \
    --max_seq_length=256 \
    $add1 $add2 $add3
    
CUDA_VISIBLE_DEVICES=$gpu python main.py \
    --my_model=dual_encoder_ranking \
    --do_train \
    --dataset='["universal_act_sim_joint"]' \
    --task=nlg --task_name=rs \
    --example_type=turn \
    --model_type=${model} \
    --model_name_or_path=${bert_dir} \
     --output_dir=${output_dir}/RS/SIM_JOINT-Ratio/R${ratio} \
    --batch_size=25 --eval_batch_size=100 \
    --eval_by_step=250 \
    --train_data_ratio=${ratio} \
    --max_seq_length=256 \
    $add1 $add2 $add3
done

