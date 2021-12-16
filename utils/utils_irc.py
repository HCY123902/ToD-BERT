import json
import ast
import os

from .utils_function import get_input_example

def read_langs_movie_turn(file_name, max_line = None):
    print(("Reading from {} for read_langs_movie_dial".format(file_name)))
    
    data = []
    domain_counter = {} 
    
    with open(file_name) as f:
        dials = json.load(f)
        
        print("len dials", len(dials))
        
        cnt_lin = 1
        for dial_count, dial_list in enumerate(dials):
            if dial_count >= 5000:
                print("Retain the first 5000 dialogues")
                break
            
            dialog_history = []
            
            # sys_first_flag = 1 if (dial_list[0]["speaker"]=="[SYS]") else 0
            sys_first_flag = 0
            
            # Reading data
            for ti, turn in enumerate(dial_list):

                data_detail = get_input_example("turn")

                # data_detail["ID"] = turn["conv_id"]
                data_detail["ID"] = dial_count

                data_detail["dialog_history"] = list(dialog_history)
                
                if sys_first_flag and ti % 2 == 1:
                    data_detail["turn_id"] = ti//2
                    data_detail["turn_usr"] = "{}: {}".format(turn["speaker"], turn["utterance"].strip())
                    data_detail["turn_sys"] = "{}: {}".format(dial_list[ti-1]["speaker"], dial_list[ti-1]["utterance"].strip())
                    data_detail["sys_act"] = dial_list[ti-1]["label"]
                    data.append(data_detail)
                    dialog_history.append(data_detail["turn_sys"])
                    dialog_history.append(data_detail["turn_usr"])
                elif not sys_first_flag and ti % 2 == 0:
                    data_detail["turn_id"] = (ti+1)//2
                    data_detail["turn_usr"] = "{}: {}".format(turn["speaker"], turn["utterance"].strip())
                    data_detail["turn_sys"] = "{}: {}".format(dial_list[ti-1]["speaker"], dial_list[ti-1]["utterance"].strip()) if ti > 0 else ""
                    data_detail["sys_act"] = dial_list[ti-1]["label"] if ti > 0 else []
                    data.append(data_detail)
                    dialog_history.append(data_detail["turn_sys"])
                    dialog_history.append(data_detail["turn_usr"])
                
            cnt_lin += 1
            if(max_line and cnt_lin >= max_line):
                break

    return data

def read_langs_irc_turn(file_name, max_line = None):
    print(("Reading from {} for read_langs_irc_turn".format(file_name)))
    
    data = []
    domain_counter = {} 
    
    with open(file_name) as f:
        lines = f.readlines()
        dials = []
        for line in lines:
            dial = [c.strip() for c in line.split("__eou__")[:-1]]
            dials.append(dial)
        
        print("len dials", len(dials))
        
        cnt_lin = 1
        for dial_count, dial_list in enumerate(dials):
            dialog_history = []
            
            #sys_first_flag = 1 if (dial_list[0]["speaker"]=="[SYS]") else 0
            sys_first_flag = 0
            
            # Reading data
            for ti, turn in enumerate(dial_list):

                data_detail = get_input_example("turn")

                #data_detail["ID"] = turn["conv_id"]
                data_detail["ID"] = dial_count

                data_detail["dialog_history"] = list(dialog_history)
                
                if sys_first_flag and ti % 2 == 1:
                    data_detail["turn_id"] = ti//2
                    data_detail["turn_usr"] = turn.strip()
                    data_detail["turn_sys"] = dial_list[ti-1].strip()
                    #data_detail["sys_act"] = dial_list[ti-1]["label"]
                    data_detail["sys_act"] = "inform"

                    data.append(data_detail)
                    dialog_history.append(data_detail["turn_sys"])
                    dialog_history.append(data_detail["turn_usr"])
                elif not sys_first_flag and ti % 2 == 0:
                    data_detail["turn_id"] = (ti+1)//2
                    data_detail["turn_usr"] = turn.strip()
                    data_detail["turn_sys"] = dial_list[ti-1].strip() if ti > 0 else ""
                    #data_detail["sys_act"] = dial_list[ti-1]["label"] if ti > 0 else []
                    data_detail["sys_act"] = "inform"

                    data.append(data_detail)
                    dialog_history.append(data_detail["turn_sys"])
                    dialog_history.append(data_detail["turn_usr"])
                
            cnt_lin += 1
            if(max_line and cnt_lin >= max_line):
                break

    return data

def read_langs_dial(file_name, label_dict, max_line = None):
    raise NotImplementedError


def prepare_data_movie(args):
    example_type = args["example_type"]
    max_line = args["max_line"]
    
    file_trn = os.path.join(args["data_path"], 'movie/train.json')
    file_dev = os.path.join(args["data_path"], 'movie/valid.json')
    file_tst = os.path.join(args["data_path"], 'movie/test.json')
    #file_label = os.path.join(args["data_path"], 'universal_dialog_act/dstc2/labels.txt')
    #file_label = '/export/home/dialog_datasets/universal_dialog_act/acts.txt'
    #label_dict = {line.replace("\n", ""):i for i, line in enumerate(open(file_label, "r").readlines())}
    
    _example_type = "dial" if "dial" in example_type else example_type
    # _example_type = "turn"

    pair_trn = globals()["read_langs_movie_{}".format(_example_type)](file_trn, max_line)
    pair_dev = globals()["read_langs_movie_{}".format(_example_type)](file_dev, max_line)
    pair_tst = globals()["read_langs_movie_{}".format(_example_type)](file_tst, max_line)

    print("Read {} pairs train from {}".format(len(pair_trn), file_trn))
    print("Read {} pairs valid from {}".format(len(pair_dev), file_dev))
    print("Read {} pairs test from  {}".format(len(pair_tst), file_tst)) 
    
    # meta_data = {"sysact":label_dict, "num_labels":len(label_dict)}
    meta_data = {}
    print("meta_data", meta_data)

    return pair_trn, pair_dev, pair_tst, meta_data


def prepare_data_irc(args):
    example_type = args["example_type"]
    max_line = args["max_line"]
    
    file_trn = os.path.join(args["data_path"], 'irc/train.txt')
    file_dev = os.path.join(args["data_path"], 'irc/valid.txt')
    file_tst = os.path.join(args["data_path"], 'irc/test.txt')
    # file_label = os.path.join(args["data_path"], 'universal_dialog_act/sim_joint/labels.txt')
    # file_label = '/export/home/dialog_datasets/universal_dialog_act/acts.txt'
    # label_dict = {line.replace("\n", ""):i for i, line in enumerate(open(file_label, "r").readlines())}
    
    _example_type = "dial" if "dial" in example_type else example_type
    # _example_type = "turn"

    pair_trn = globals()["read_langs_irc_{}".format(_example_type)](file_trn, max_line)
    pair_dev = globals()["read_langs_irc_{}".format(_example_type)](file_dev, max_line)
    pair_tst = globals()["read_langs_irc_{}".format(_example_type)](file_tst, max_line)

    print("Read {} pairs train from {}".format(len(pair_trn), file_trn))
    print("Read {} pairs valid from {}".format(len(pair_dev), file_dev))
    print("Read {} pairs test from  {}".format(len(pair_tst), file_tst)) 
    
    # meta_data = {"sysact":label_dict, "num_labels":len(label_dict)}
    meta_data = {}
    print("meta_data", meta_data)

    return pair_trn, pair_dev, pair_tst, meta_data
